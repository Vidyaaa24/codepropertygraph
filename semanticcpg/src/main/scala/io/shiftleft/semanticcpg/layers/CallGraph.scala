package io.shiftleft.semanticcpg.layers

import io.shiftleft.codepropertygraph.Cpg
import io.shiftleft.passes.CpgPassBase
import io.shiftleft.semanticcpg.passes.callgraph.{DynamicCallLinker, MethodRefLinker, StaticCallLinker}

object CallGraph {
  val overlayName: String = "callgraph"
  val description: String = "Call graph layer"
  def defaultOpts = new LayerCreatorOptions()

  def passes(cpg: Cpg): Iterator[CpgPassBase] = {
    Iterator(
      new MethodRefLinker(cpg),
      new StaticCallLinker(cpg),
      new DynamicCallLinker(cpg),
    )
  }

}

class CallGraph extends LayerCreator {
  override val overlayName: String = CallGraph.overlayName
  override val description: String = CallGraph.description
  override val dependsOn = List(TypeRelations.overlayName)

  override def create(context: LayerCreatorContext, storeUndoInfo: Boolean): Unit = {
    val cpg = context.cpg
    CallGraph.passes(cpg).zipWithIndex.foreach {
      case (pass, index) =>
        runPass(pass, context, storeUndoInfo, index)
    }
  }

  // LayerCreators need one-arg constructor, because they're called by reflection from io.joern.console.Run
  def this(optionsUnused: LayerCreatorOptions) = this()
}