require 'sqlite3'
require 'singleton'
# require_relative 'question'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def followed_quesitons
    QuestionFollows.followed_questions_for_user_id(@id)
  end

  def authored_questions
    raise "#{self} not in database" unless @id
    Question.find_by_author_id(@id)
  end

  def authored_replies
    raise "#{self} not in database" unless @id
    Reply.find_by_user_id(@id)
  end


  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end
end

#=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-==-=-=-=-=-=-=-=---==
class Question
  attr_accessor :title, :body, :user_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author_id(user_id)
    QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def author
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        user_id
      FROM
        questions
      WHERE
        id = ?
    SQL
  end

  def replies
    raise "#{self} not in database" unless @id
    Reply.find_by_question_id(@id)
  end


  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions(title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
end

#========================================================

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.most_followed_questions(n)
    QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      title, body
    FROM
      question_follows
      JOIN
        questions on questions.id = question_follows.question_id

    GROUP BY
      question_id
    ORDER BY
      COUNT(*) DESC
    LIMIT ?


    SQL
  end

  def self.followers_for_question_id(question_id)
    QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        question_follows.user_id, title, body
      FROM
        questions
        JOIN
          question_follows ON questions.id = question_follows.question_id
      WHERE
        questions.id = ?

    SQL
  end

  def self.followed_questions_for_user_id(user_id)
    QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, title, body
      FROM
        question_follows
      JOIN questions ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_follows(user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_follows
      SET
        user_id = ?, question_id  = ?
      WHERE
        id = ?
    SQL
  end

  def delete
  end

end


#========================================================

class Reply
  attr_accessor :body, :question_id, :parent_reply, :user_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(user_id)
    QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
  end

  def self.find_by_question_id(question_id)
    QuestionsDBConnection.instance.execute(<<-SQL, question_id)
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
