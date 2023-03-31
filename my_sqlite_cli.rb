require "./my_sqlite_request.rb"


class MySqliteCLI

    attr_accessor :valid_cmnds, :cmnd_hash, :cur_token, :cmnd_split, :query, :table_holder, :token_arr, :cli_alive

    def initialize
        @valid_cmnds = ["select", "from", "where", "order",  "update", "set", "insert", "values", "delete"]
        @cmnd_hash ={}
        @token_arr = []
        @cur_token = ""
        @cmnd_split = []
        @cli_alive = true
        @table_holder = ARGV[0]
        @valid_cmnds.each do |cmnd|
            @cmnd_hash[cmnd] =[]
        end
    end

    def reset_cmnd_hash
        @valid_cmnds.each do |cmnd|
            @cmnd_hash[cmnd] =[]
        end
    end

    def read_input
        if ARGV.length > 0
            ARGV.clear
        end
        print "my_sqlite_cli> "
        @token_arr = gets.chomp.split(";")
    end


    def clean_input
        if @cur_token.casecmp?("quit")
            @cli_alive = false
        end
        @cur_token.delete!('()=\'')
        @cur_token.gsub! ',', ' '
        @cur_token.slice! "INTO"
        @cmnd_split = @cur_token.split(' ')
        return true
    end

    def parse_input
        # account for Delete
        if @cmnd_split[0].casecmp?("delete")
            @cmnd_hash['delete'].append("Delete")
        end
        arg_i = 0;
        cmnd_i = 0
        while(arg_i < @cmnd_split.length)
            if @valid_cmnds.include?(@cmnd_split[cmnd_i].downcase)
                while(arg_i+1 < @cmnd_split.length && !@valid_cmnds.include?(@cmnd_split[arg_i+1].downcase))
                    @cmnd_hash[@cmnd_split[cmnd_i].downcase].append(@cmnd_split[arg_i+=1])
                end
            end
            arg_i += 1
            cmnd_i = arg_i
        end
    end

    def format_output(hash_array)
        hash_array.each do |row|
            out_str = ""
            row.each do |key, value|
                out_str += value
                out_str += "|"
            end
            out_str = out_str.slice(0..-2)
            print(out_str+"\n")
        end
    end

    def build_select
        req = MySqliteRequest.new
        req.select(*cmnd_hash['select'])
        req.from(cmnd_hash['from'][0])
        if cmnd_hash['where'].length > 0
            req.where(cmnd_hash['where'][0], cmnd_hash['where'][1])
        end
        @query = req.run
        format_output(@query)
    end

    def build_insert
        if cmnd_hash['insert'][0].casecmp?("into")
            cmnd_hash['insert'].shift
        end
        req = MySqliteRequest.new
        req.insert(cmnd_hash['insert'][0])
        keys = cmnd_hash['insert'][1..]
        req.values(Hash[keys.zip(cmnd_hash['values'])])
        req.run
    end

    def build_update
        req = MySqliteRequest.new
        req.update(cmnd_hash['update'][0])
        req.set(Hash[*cmnd_hash['set'].flatten(1)])
        req.where(cmnd_hash['where'][0], cmnd_hash['where'][1])
        req.run
    end

    def build_delete
        req = MySqliteRequest.new
        req.where(cmnd_hash['where'][0], cmnd_hash['where'][1])
        req.from(cmnd_hash['from'][0])
        req.delete
        req.run
    end

    def interpret_input
        if cmnd_hash['select'].length > 0
            self.build_select
        elsif cmnd_hash['insert'].length > 0
            self.build_insert
        elsif cmnd_hash['update'].length > 0
            self.build_update
        elsif cmnd_hash['delete'].length > 0
            self.build_delete
        end
    end

    def execute_commands
        @token_arr.each do |cmnd|
            @cur_token = cmnd
            self.clean_input
            self.parse_input
            self.interpret_input
            self.reset_cmnd_hash
        end
    end

    def listen
        while @cli_alive
            self.read_input
            self.execute_commands
        end
    end
    
end

sql_cli = MySqliteCLI.new
sql_cli.listen