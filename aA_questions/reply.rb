require 'user'
require 'question'


class Reply
  attr_accessor :body, :question_id, :parent_reply, :user_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(user_id)
    QuestionsDBConnection.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
  end

  def self.find_by_question_id(question_id)
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id= ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
  end

  def author
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        user_id
      FROM
        replies
      WHERE
        id = ?
    SQL
  end

  def question
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        question_id
      FROM
        replies
      WHERE
        id = ?
    SQL
  end

  def parent_reply
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
  end

  def child_replies
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
  end


  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @body, @question_id, @parent_reply, @user_id)
      INSERT INTO
        replies(body, question_id, parent_reply, user_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @body, @question_id, @parent_reply, @user_id)
      UPDATE
        questions
      SET
        body = ?, quesiton_id = ?, parent_reply = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
end
