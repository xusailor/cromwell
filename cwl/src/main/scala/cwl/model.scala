package cwl

import cats.instances.list._
import cats.syntax.either._
import cats.syntax.option._
import cats.syntax.traverse._
import common.validation.ErrorOr.ErrorOr
import cwl.CommandLineTool.{CommandBindingSortingKey, SortKeyAndCommandPart}
import cwl.LinkMergeMethod.LinkMergeMethod
import cwl.WorkflowStepInput.InputSource
import cwl.command.ParentName
import eu.timepit.refined._
import shapeless.syntax.singleton._
import shapeless.{:+:, CNil, Witness}
import wom.graph.GraphNodePort.OutputPort
import wom.graph.WomIdentifier
import wom.graph.expression.{ExposedExpressionNode, ExpressionNode}
import wom.types.{WomStringType, WomType}
import wom.values.WomValue

case class WorkflowStepInput(
  id: String,
  source: Option[InputSource] = None,
  linkMerge: Option[LinkMergeMethod] = None,
  default: Option[CwlAny] = None,
  valueFrom: Option[StringOrExpression] = None) {
  
  def toExpressionNode(sourceMappings: Map[String, OutputPort],
                       outputTypeMap: Map[String, WomType],
                       expressionLib: ExpressionLib
                      )(implicit parentName: ParentName): ErrorOr[ExpressionNode] = {

    val sources = source.toList.flatMap(_.fold(WorkflowStepInputSourceToStrings))

    val inputs = sourceMappings.keySet

    def lookupId(id: String): ErrorOr[WomType] =
      outputTypeMap.
        get(id).
        toValidNel(s"couldn't find $id as derived from $source in map\n${outputTypeMap.mkString("\n")}")

    (for {
      //lookup each of our source Ids, failing if any of them are missing
      inputTypes <- sources.traverse[ErrorOr, WomType](lookupId).toEither
      // we may have several sources, we make sure to have a type common to all of them.
      // In the case where there's no input source, we currently wrap the valueFrom value in a WomString (see WorkflowStepInputExpression)
      inputType = if (inputTypes.isEmpty) WomStringType else WomType.homogeneousTypeFromTypes(inputTypes)
      womExpression = WorkflowStepInputExpression(this, inputType, inputs, expressionLib)
      identifier = WomIdentifier(id)
      ret <- ExposedExpressionNode.fromInputMapping(identifier, womExpression, inputType, sourceMappings).toEither
    } yield ret).toValidated
  }
}

object WorkflowStepInput {
  type InputSource = String :+: Array[String] :+: CNil
}

object WorkflowStepInputSource {
  object String {
    def unapply(arg: InputSource): Option[String] = arg.select[String]
  }
  object StringArray {
    def unapply(arg: InputSource): Option[Array[String]] = arg.select[Array[String]]
  }
}

case class InputRecordSchema(
  `type`: W.`"record"`.T,
  fields: Option[Array[InputRecordField]],
  label: Option[String])

case class InputRecordField(
  name: String,
  `type`: MyriadInputType,
  doc: Option[String],
  inputBinding: Option[InputCommandLineBinding],
  label: Option[String])

case class InputEnumSchema(
  symbols: Array[String],
  `type`: W.`"enum"`.T,
  label: Option[String],
  inputBinding: Option[InputCommandLineBinding])

case class InputArraySchema(
  items: MyriadInputType,
  `type`: W.`"array"`.T = Witness("array").value,
  label: Option[String] = None,
  inputBinding: Option[InputCommandLineBinding] = None)

trait CommandLineBinding {
  def loadContents: Option[Boolean]
  def position: Option[Int]
  def prefix: Option[String]
  def separate: Option[Boolean]
  def itemSeparator: Option[String]
  def optionalValueFrom: Option[StringOrExpression]
  def shellQuote: Option[Boolean]
  // separate defaults to true
  def effectiveSeparate = separate.getOrElse(true)
}

case class InputCommandLineBinding(
                               loadContents: Option[Boolean] = None,
                               position: Option[Int] = None,
                               prefix: Option[String] = None,
                               separate: Option[Boolean] = None,
                               itemSeparator: Option[String] = None,
                               valueFrom: Option[StringOrExpression] = None,
                               shellQuote: Option[Boolean] = None) extends CommandLineBinding {
  override val optionalValueFrom = valueFrom

  def toCommandPart(sortingKey: CommandBindingSortingKey, boundValue: WomValue, expressionLib: ExpressionLib) = {
    SortKeyAndCommandPart(sortingKey, InputCommandLineBindingCommandPart(this, boundValue)(expressionLib))
  }
}

// valueFrom is required for command line bindings in the argument section: http://www.commonwl.org/v1.0/CommandLineTool.html#CommandLineBinding
case class ArgumentCommandLineBinding(
                               valueFrom: StringOrExpression,
                               loadContents: Option[Boolean] = None,
                               position: Option[Int] = None,
                               prefix: Option[String] = None,
                               separate: Option[Boolean] = None,
                               itemSeparator: Option[String] = None,
                               shellQuote: Option[Boolean] = None) extends CommandLineBinding {
  override val optionalValueFrom = Option(valueFrom)
}

case class InputBinding(position: Int, prefix: String)

case class OutputRecordSchema(
  `type`: W.`"record"`.T,
  fields: Option[Array[OutputRecordField]],
  label: Option[String])

case class OutputRecordField(
  name: String,
  `type`: MyriadOutputType,
  doc: Option[String],
  outputBinding: Option[CommandOutputBinding])

case class OutputEnumSchema(
  symbols: Array[String],
  `type`: W.`"enum"`.T,
  label: Option[String],
  outputBinding: Option[CommandOutputBinding])



case class OutputArraySchema(
  items: MyriadOutputType,
  `type`: W.`"array"`.T = Witness("array").value,
  label: Option[String] = None,
  outputBinding: Option[CommandOutputBinding] = None)


case class InlineJavascriptRequirement(
  `class`: W.`"InlineJavascriptRequirement"`.T = "InlineJavascriptRequirement".narrow,
  expressionLib: Option[Array[String]] = None)

case class SchemaDefRequirement(
  `class`: W.`"SchemaDefRequirement"`.T,
  types: Array[InputRecordSchema :+: InputEnumSchema :+: InputArraySchema :+: CNil]
  )

//There is a large potential for regex refinements on these string types
case class DockerRequirement(
  `class`: W.`"DockerRequirement"`.T,
  dockerPull: Option[String], //TODO Refine to match a docker image regex?
  dockerLoad: Option[String],
  dockerFile: Option[String],
  dockerImport: Option[String],
  dockerImageId: Option[String],
  dockerOutputDirectory: Option[String]
  )

case class SoftwareRequirement(
  `class`: W.`"SoftwareRequirement"`.T,
  packages: Array[SoftwarePackage] = Array.empty
  )

case class SoftwarePackage(
  `package`: String,
  version: Option[Array[String]],
  specs: Option[Array[String]] // This could be refined to match a regex for IRI.
  ) {
  type Package = String
  type Specs = Array[String]
}

case class EnvVarRequirement(
                              `class`: EnvVarRequirement.ClassType = EnvVarRequirement.`class`,
                              envDef: Array[EnvironmentDef]
                            )

object EnvVarRequirement {
  type ClassType = Witness.`"EnvVarRequirement"`.T

  val `class`: ClassType = "EnvVarRequirement".asInstanceOf[ClassType]
}

case class EnvironmentDef(envName: String, envValue: StringOrExpression) {
  type EnvName = String
  type EnvValue = String
}


case class ShellCommandRequirement(`class`: W.`"ShellCommandRequirement"`.T = "ShellCommandRequirement".narrow)

case class ResourceRequirement(
                                `class`: W.`"ResourceRequirement"`.T,
                                coresMin: Option[ResourceRequirementType],
                                coresMax: Option[ResourceRequirementType],
                                ramMin: Option[ResourceRequirementType],
                                ramMax: Option[ResourceRequirementType],
                                tmpdirMin: Option[ResourceRequirementType],
                                tmpdirMax: Option[ResourceRequirementType],
                                outdirMin: Option[ResourceRequirementType],
                                outdirMax: Option[ResourceRequirementType]) {
  def effectiveCoreMin = coresMin.orElse(coresMax)
  def effectiveCoreMax = coresMax.orElse(coresMin)
  
  def effectiveRamMin = ramMin.orElse(ramMax)
  def effectiveRamMax = ramMax.orElse(ramMin)
  
  def effectiveTmpdirMin = tmpdirMin.orElse(tmpdirMax)
  def effectiveTmpdirMax = tmpdirMax.orElse(tmpdirMin)
  
  def effectiveOutdirMin = outdirMin.orElse(outdirMax)
  def effectiveOutdirMax = outdirMax.orElse(outdirMin)
}

case class SubworkflowFeatureRequirement(
  `class`: W.`"SubworkflowFeatureRequirement"`.T)

case class ScatterFeatureRequirement(
  `class`: W.`"ScatterFeatureRequirement"`.T)

case class MultipleInputFeatureRequirement(
  `class`: W.`"MultipleInputFeatureRequirement"`.T)

case class StepInputExpressionRequirement(
  `class`: W.`"StepInputExpressionRequirement"`.T)
