require_relative "../config/environment.rb"

class Student

    #### Attributes ####
    attr_accessor :id, :name, :grade

    #### Instance Methods ####
    def initialize(id=nil, name, grade)
        @id = id
        @name = name
        @grade = grade
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO students (name, grade)
                VALUES (?, ?)
                SQL

            DB[:conn].execute(sql, self.name, self.grade)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        end
    end

    def update
        sql = <<-SQL
            UPDATE students
            SET name = ?, grade = ?
            WHERE id = ?
            SQL

        DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

    #### Class Methods####

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS students (
                id INTEGER PRIMARY KEY,
                name TEXT,
                grade TEXT
                )
                SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE students
            SQL

        DB[:conn].execute(sql)
    end

    def self.create(name, grade)
        new_student = self.new(name,grade)
        new_student.save
        new_student
    end

    def self.new_from_db(row)
        self.new(row[0], row[1], row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM students
            WHERE name = ?
            SQL

        DB[:conn].execute(sql, name).map do |student|
            self.new_from_db(student)
        end.first
    end
end
