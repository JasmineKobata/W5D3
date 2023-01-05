require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class User
    attr_accessor :id, :fname, :lname

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM users")
        p data
        data.map { |instance| User.new(instance)}
    end

    def self.find_by_id(id)
        raise "#{id} not in database" if !id
        user = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM users
            WHERE id = ?
        SQL
        return nil unless user.length > 0

        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        raise "#{fname}, #{lname} not in database" if !fname || !lname
        user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT *
            FROM users
            WHERE fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0

        User.new(user.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end 
    
    def authored_questions
        q_arr = Question.find_by_author_id(self.id)
        return nil unless q_arr.length > 0
        q_arr
    end

    def authored_replies
        q_arr = Reply.find_by_user_id(self.id)
        return nil unless q_arr.length > 0
        q_arr
    end
end

class Question
    attr_accessor :id, :text, :body, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
        data.map { |instance| Question.new(instance)}
    end

    def self.find_by_id(id)
        raise "#{id} not in database" if !id
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions
            WHERE id = ?
        SQL
        return nil unless question.length > 0

        Question.new(question.first)
    end

    def self.find_by_author_id(author_id)
        raise "#{author_id} not in database" if !author_id
        questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT *
            FROM questions
            WHERE user_id = ?
        SQL
        return nil unless questions.length > 0

        questions.map {|instance| Question.new(instance) }
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def author
        user = User.find_by_id(self.user_id)
        return nil if user == nil
        user
    end

    def replies
        user = Reply.find_by_question_id(self.id)
        return nil unless user.length > 0
        user
    end
end

class QuestionFollow
    attr_accessor :id, :question_id, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions_follows")
        data.map { |instance| QuestionFollow.new(instance)}
    end

    def self.find_by_id(id)
        raise "#{id} not in database" if !id
        qfollow = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions_follows
            WHERE id = ?
        SQL
        return nil unless qfollow.length > 0

        Question.new(qfollow.first)
    end

    def self.followers_for_questions_id(question_id)
        raise "#{question_id} not in database" if !question_id
        followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM questions_follows
            JOIN users
                ON questions_follows.user_id = users.id
            WHERE questions_follows.question_id = ?
        SQL
        return nil unless followers.length > 0

        followers.map { |instance| User.new(instance) }
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end

class Reply
    attr_accessor :id, :question_id, :parent_reply_id, :user_id, :body

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
        data.map { |instance| Reply.new(instance)}
    end

    def self.find_by_id(id)
        raise "#{id} not in database" if !id
        reply = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        return nil unless reply.length > 0

        Reply.new(reply.first)
    end

    def self.find_by_user_id(user_id)
        raise "#{user_id} not in database" if !user_id
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM replies
            WHERE user_id = ?
        SQL
        return nil unless replies.length > 0

        replies.map { |instance| Reply.new(instance) }
    end

    def self.find_by_question_id(question_id)
        raise "#{question_id} not in database" if !question_id
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM replies
            WHERE question_id = ?
        SQL
        return nil unless replies.length > 0

        replies.map { |reply| Reply.new(reply) }
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @parent_reply_id = options['parent_reply_id']
        @user_id = options['user_id']
        @body = options['body']
    end

    def author
        user = User.find_by_id(self.user_id)
        return nil if user == nil
        user
    end

    def question
        question = Question.find_by_id(self.question_id)
        return nil if question == nil
        question
    end

    def parent_reply
        return nil if self.parent_reply_id == nil
        reply = Reply.find_by_id(self.parent_reply_id)
        reply
    end

    def child_replies
        replies = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT *
            FROM replies
            WHERE parent_reply_id = ?
        SQL
        return nil unless replies.length > 0

        replies.map { |reply| Reply.new(reply) }
    end
end

class QuestionLike
    attr_accessor :id, :question_id, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
        data.map { |instance| QuestionLike.new(instance)}
    end

    def self.find_by_id(id)
        raise "#{id} not in database" if !id
        qlike = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM question_likes
            WHERE id = ?
        SQL
        return nil unless qlike.length > 0

        QuestionLike.new(qlike.first)
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end