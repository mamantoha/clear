module Clear::SQL::Query::OffsetLimit
  macro included
    getter limit : Int64? = nil
    getter offset : Int64? = nil
  end

  def limit(x : Int?)
    @limit = Int64.new(x)
    self
  end

  def clear_limit
    @limit = nil
    self
  end

  def clear_offset
    @offset = nil
  end

  def offset(x : Int?)
    @offset = Int64.new(x)
    self
  end

  protected def print_limit_offsets
    [@limit && ("LIMIT #{@limit}"), @offset && "OFFSET #{@offset}"].compact.join(" ")
  end
end
