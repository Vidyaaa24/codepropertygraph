package io.shiftleft.codepropertygraph.schema

trait SchemaBase {
  // Used for ordering in the documentation. Smallest index shows up first.
  def index: Int
  def description: String
  def providedByFrontend: Boolean = false
}
