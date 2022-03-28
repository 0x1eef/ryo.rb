module Proto::ObjectMixin
  def create(prototype, &b)
    Class.new(BasicObject) do
      include Proto
      class_eval(&b) if b
    end.new(prototype)
  end
end
