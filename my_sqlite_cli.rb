require "./my_sqlite_request.rb"


class MySqlitCLI

    attr_accessor :valid_cmnds, :cmnd_hash, :cur_token, :cmnd_split, :query, :table_holder

    def initialize
        @valid_cmnds = ["select", "from", "where", "order",  "update", "set", "insert", "values", "delete"]
        @cmnd_hash ={}
        @cur_token = ""
        @cmnd_split = []
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
        @cur_token = gets.chomp
        @cur_token.delete!('();=\'')
        @cur_token.gsub! ',', ' '
        @cur_token.slice! "INTO"
        @cmnd_split = @cur_token.split(' ')
    end

    def parse_input
        # account for Delete
        p @cmnd_split
        if @cmnd_split[0].casecmp("delete")
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
        req.select(cmnd_hash['select'][0])
        req.from(cmnd_hash['from'][0])
        if cmnd_hash['where'].length > 0
            req.where(cmnd_hash['where'][0], cmnd_hash['where'][1])
        end
        @query = req.run
        format_output(@query)
    end

    # def make_insert_hash(table_name, val_arr)
    #     keyes = CSV.parse(File.read(@insert_table), headers: true).headers
    #     r_hash = {}
    #     (0..val_arr.length).each do |i|
    #         r_hash[keyes[i]] = val_arr[i]
    #     end
    #     return r_hash
    # end

    def build_insert
        if cmnd_hash['insert'][0].casecmp("into")
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
        p Hash[*cmnd_hash['set'].flatten(1)]
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
            p 'select'
            self.build_select
        elsif cmnd_hash['insert'].length > 0
            p 'insert'
            self.build_insert
        elsif cmnd_hash['update'].length > 0
            p 'update'
            self.build_update
        elsif cmnd_hash['delete'].length > 0
            p cmnd_hash
            p 'delete'
            self.build_delete
        end
    end

    def listen
        self.read_input
        while @cur_token != 'quit'
            self.read_input
            self.parse_input
            self.interpret_input
            self.reset_cmnd_hash
        end
    end
    
end

sql_cli = MySqlitCLI.new
sql_cli.listen