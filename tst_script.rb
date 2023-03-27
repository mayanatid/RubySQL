require 'rspec'

RSpec.describe "My SQLite" do
    describe 'files are presents' do
      it 'should have a my_sqlite_request.rb file' do

        if File.exists?("my_sqlite_request.rb") == false
          abort("my_sqlite_request.rb not found")
        end
        if File.exists?("my_sqlite_cli.rb") == false
          abort("my_sqlite_cli.rb not found")
        end
      end
    end

    describe 'Model' do
      def seed_insert(seed)
        MySqliteRequest.insert('database.csv').values('firstname' => "Thomas_#{seed}", 'lastname' => "Anderson_#{seed}", 'age' => 33, 'password' => 'matrix').run
      end


      before :all do
        require "./my_sqlite_request.rb"
      end
      
      before :each do        
        @firstname  = 'Thomas'
        @lastname   = 'Anderson'
        @age        = 33
        @password   = 'matrix'
        @email      = 'neo@matrix.world'

        FileUtils.rm_f("database.csv")
      end
      
      
      describe 'initialize' do
        it 'new without parameter' do

          expect(MySqliteRequest.new).to be_a(MySqliteRequest)
        end
      end


      describe 'insert' do
        describe 'insert' do
          it 'from an instance' do

            expect(MySqliteRequest.new.insert('database.csv')).to be_a(MySqliteRequest)
          end


          it 'from as static' do
            expect(MySqliteRequest.insert('database.csv')).to be_a(MySqliteRequest)
          end
        end


        describe 'values' do
          it 'takes a hash' do

            expect(MySqliteRequest.new.values(['key_a' => 'value_a', 'key_b' => 'value_b', 'key_c' => 'value_c'])).to be_a(MySqliteRequest)
          end
        end


        describe 'run()' do
          it 'should work' do
            MySqliteRequest.insert('database.csv').values('firstname' => "Thomas", 'lastname' => "Anderson", 'age' => 33, 'password' => 'matrix').run()
          end
        end
      end


      describe 'select' do
        describe 'from' do
          it 'from an instance' do
            expect(MySqliteRequest.new.from('database.csv')).to be_a(MySqliteRequest)
          end


          it 'from as static' do
            expect(MySqliteRequest.from('database.csv')).to be_a(MySqliteRequest)
          end
        end


        describe 'select' do
          it 'with one parameter' do

            expect(MySqliteRequest.new.select('column_a')).to be_a(MySqliteRequest)
          end


          it 'with multiple parameters' do
            expect(MySqliteRequest.new.select('column_a', 'column_b', 'column_c', 'column_d')).to be_a(MySqliteRequest)
          end
        end


        describe 'where' do
          it 'takes two parameters' do

            expect(MySqliteRequest.new.where('column_a', '13')).to be_a(MySqliteRequest)
          end
        end


        describe 'join' do
          it 'takes three parameters' do

            expect(MySqliteRequest.new.join('column_on_db_a', 'filename_db_b', 'column_on_db_b')).to be_a(MySqliteRequest)
          end
        end


        describe 'order' do
          it 'takes two parameters' do

            expect(MySqliteRequest.new.order(:asc, 'column_a')).to be_a(MySqliteRequest)
          end
        end

        describe 'run()' do
          it 'should return an array of data' do
            seed_insert(1)
            seed_insert(2)


            expect(MySqliteRequest.from('database.csv').select('firstname', 'lastname').run()).to eq([{"firstname"=>"Thomas_1", "lastname"=>"Anderson_1"}, {"firstname"=>"Thomas_2", "lastname"=>"Anderson_2"}])
          end


          it 'should return an array of data' do
            seed_insert(1)
            seed_insert(2)


            expect(MySqliteRequest.from('database.csv').select('firstname', 'lastname', 'age').run()).to eq([{"age"=>"33", "firstname"=>"Thomas_1", "lastname"=>"Anderson_1"}, {"age"=>"33", "firstname"=>"Thomas_2", "lastname"=>"Anderson_2"}])
          end


          it 'should return an array of data order desc' do
            seed_insert(1)
            seed_insert(2)


            expect(MySqliteRequest.from('database.csv').order(:desc, 'firstname').select('firstname', 'lastname', 'age').run()).to eq([{"age"=>"33", "firstname"=>"Thomas_2", "lastname"=>"Anderson_2"}, {"age"=>"33", "firstname"=>"Thomas_1", "lastname"=>"Anderson_1"}])
          end


          it 'should return an array of data' do
            seed_insert(1)
            seed_insert(2)


            expect(MySqliteRequest.from('database.csv').select('firstname', 'lastname', 'age').where('firstname', 'Thomas_2').run()).to eq([{"age"=>"33", "firstname"=>"Thomas_2", "lastname"=>"Anderson_2"}])
          end
        end
      end


      describe 'update' do
        describe 'update' do
          it 'from an instance' do

            expect(MySqliteRequest.new.update('database.csv')).to be_a(MySqliteRequest)
          end


          it 'from as static' do
            expect(MySqliteRequest.update('database.csv')).to be_a(MySqliteRequest)
          end
        end


        describe 'set' do
          it 'takes a hash' do

            expect(MySqliteRequest.new.set('key_a' => 'value_a', 'key_b' => 'value_b', 'key_c' => 'value_c')).to be_a(MySqliteRequest)
          end
        end

        describe 'run()' do
          it 'should return an array of data' do
            seed_insert(1)
            seed_insert(2)
            seed_insert(3)

            MySqliteRequest.update('database.csv').where('firstname', 'Thomas_2').set('lastname' => 'Anderson_11').run()

            expect(MySqliteRequest.from('database.csv').select('firstname', 'lastname', 'age').run()).to eq([{"age"=>"33", "firstname"=>"Thomas_1", "lastname"=>"Anderson_1"}, {"age"=>"33", "firstname"=>"Thomas_2", "lastname"=>"Anderson_11"}, {"age"=>"33", "firstname"=>"Thomas_3", "lastname"=>"Anderson_3"}])
          end
        end
      end


      describe 'delete' do
        describe 'delete' do
          it 'from an instance' do
            expect(MySqliteRequest.new.delete()).to be_a(MySqliteRequest)
          end
        end


        describe 'run()' do
          it 'should return an array of data' do
            seed_insert(1)
            seed_insert(2)
            seed_insert(3)

            MySqliteRequest.from('database.csv').where('firstname', 'Thomas_2').delete().run()

            expect(MySqliteRequest.from('database.csv').select('firstname', 'lastname', 'age').run()).to eq([{"age"=>"33", "firstname"=>"Thomas_1", "lastname"=>"Anderson_1"}, {"age"=>"33", "firstname"=>"Thomas_3", "lastname"=>"Anderson_3"}])
          end
        end
      end
    end

    describe 'CLI' do
      before :each do
        FileUtils.rm_f("database.csv")
      end
      
      it 'Zsh - CLI' do
          communicate_with('ruby my_sqlite_cli.rb database.csv') do
            send_command("ping")
          end
          expect(cw_status.signaled?).to be(false)
          expect(cw_stderr.empty?).to eq(true)
      end


      it 'INSERT + SELECT' do
        gold_stdout = "John|john@johndoe.com|http://blog.johndoe.com"
        communicate_with('ruby my_sqlite_cli.rb') do
            send_command("INSERT INTO database.csv (firstname,email,blog) VALUES (John, john@johndoe.com, https://blog.johndoe.com);")
            send_command("SELECT * FROM database.csv;")
        end

        expect(cw_status.signaled?).to be(false)
        expect(cw_stderr.empty?).to eq(true)
        expect(cw_stdout).to include(gold_stdout)
      end

      it 'INSERT + SELECT params' do
        gold_stdout = "John|john@johndoe.com"
        communicate_with('ruby my_sqlite_cli.rb') do
            send_command("INSERT INTO database.csv (firstname,email,blog) VALUES (John, john@johndoe.com, https://blog.johndoe.com);")
            send_command("SELECT firstname, email FROM database.csv;")
        end

        expect(cw_status.signaled?).to be(false)
        expect(cw_stderr.empty?).to eq(true)
        expect(cw_stdout).to include(gold_stdout)
      end


      it 'INSERT + UPDATE + SELECT' do
        gold_stdout = "Emile|emile@brave.com|https://blog.emile.com"
        communicate_with('ruby my_sqlite_cli.rb') do
            send_command("INSERT INTO database.csv (firstname,email,blog) VALUES (John, john@johndoe.com, https://blog.johndoe.com);")
            send_command("UPDATE database.csv SET firstname = 'Emile', email = 'emile@brave.com', blog = 'https://blog.emile.com' WHERE firstname = 'John'")
            send_command("SELECT * FROM database.csv;")
        end

        expect(cw_status.signaled?).to be(false)
        expect(cw_stderr.empty?).to eq(true)
        expect(cw_stdout).to include(gold_stdout)
      end

      it 'INSERT + DELETE' do
        gold_stdout = "Emile|emile@brave.com|https://blog.emile.com"
        communicate_with('ruby my_sqlite_cli.rb') do
            send_command("INSERT INTO database.csv (firstname,email,blog) VALUES (John, john@johndoe.com, https://blog.johndoe.com);")
            send_command("INSERT INTO database.csv (firstname,email,blog) VALUES (Emile, emile@brave.com, https://blog.emile.com);")
            send_command("DELETE FROM database.csv WHERE firstname = 'John'")
            send_command("SELECT * FROM database.csv;")
        end

        expect(cw_status.signaled?).to be(false)
        expect(cw_stderr.empty?).to eq(true)
        expect(cw_stdout).to include(gold_stdout)
      end
    end
end
