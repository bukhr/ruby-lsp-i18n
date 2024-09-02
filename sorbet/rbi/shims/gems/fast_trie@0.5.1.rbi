# typed: true

class Trie
  sig { void }
  def initialize; end

  sig { params(key: String).returns(T::Boolean) }
  def add(key); end

  sig { params(key: String).returns(T.nilable(Integer)) }
  def get(key); end

  sig { params(key: String).returns(T.nilable(T::Boolean)) }
  def delete(key); end

  sig { params(prefix: String).returns(T::Array[String]) }
  def children(prefix); end
end
