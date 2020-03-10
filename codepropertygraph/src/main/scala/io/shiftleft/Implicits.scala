package io.shiftleft

object Implicits {

  /**
    * A wrapper around a Java iterator that throws a proper NoSuchElementException.
    *
    * Proper in this case means an exception with a stack trace.
    * This is intended to be used as a replacement for next() on the iterators
    * returned from TinkerPop since those are missing stack traces.
    */
  implicit class JavaIteratorDeco[T](iterator: java.util.Iterator[T]) {
    def nextChecked: T = {
      try {
        iterator.next
      } catch {
        case _: CpgNoSuchElementException =>
          throw new NoSuchElementException()
      }
    }

    def onlyChecked: T = {
      if (iterator.hasNext) {
        val res = iterator.next
        assert(!iterator.hasNext, "iterator was expected to have exactly one element, but it actually has more")
        res
      } else { throw new CpgNoSuchElementException() }
    }

    def nextOption: Option[T] = {
      if (iterator.hasNext) {
        Some(iterator.next)
      } else {
        None
      }
    }
  }

  class CpgNoSuchElementException extends RuntimeException

}
