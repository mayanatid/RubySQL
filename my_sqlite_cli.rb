require "./my_sqlite_request.rb"
require 'optparse'

class MySqlitCLI

    attr_accessor :valid_cmnds, :cmnd_hash, :cur_token, :cmnd_split, :query

    def initialize
        @valid_cmnds = ["select", "from", "where", "order",  "update", "set", "insert", "values", "delete"]
        @cmnd_hash ={}
        @cur_token = ""
        @cmnd_split = []
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
        print "my_sqlite_cli> "
        @cur_token = gets.chomp
        @cur_token.delete!('();=')
        @cur_token.gsub! ',', ' '
        @cur_token.slice! "INTO"
        @cmnd_split = @cur_token.split(' ')
    end

    def parse_input
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

    def build_select
        req = MySqliteRequest.new
        req.select(cmnd_hash['select'])
        req.from(cmnd_hash['from'])
        if cmnd_hash['where'].length > 0
            req.where(cmnd_hash['where'][0], cmnd_hash['where'][1])
        end
        @query = req.run
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
        req = MySqliteRequest.new
        req.insert(cmnd_hash['insert'][0])
        keys = cmnd_hash['insert'][1..]
        req.values(Hash[keyes.zip(cmnd_hash['values'])])
        req.run
    end

    def build_update
        req = MySqliteRequest.new
        req.update(cmnd_hash['update'])
        req.set(Hash[*cmnd_hash['set'].flatten(1)])
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
    
end



sql_cli = MySqlitCLI.new
while sql_cli.cur_token != "quit"
    sql_cli.read_input
    p "current token: #{sql_cli.cur_token}"
    sql_cli.parse_input
    p "cmnd_hash: #{sql_cli.cmnd_hash.inspect}"
    sql_cli.reset_cmnd_hash
end

# tst_array = ["email", "'jane@janedoe.com'", "blog", "'https://blog.janedoe.com'"]
# p Hash[*tst_array.flatten(1)]




# arg_i = 0
# cmnd_i = 0



# while(arg_i < ARGV.length)
#     if valid_cmnds.include?(ARGV[cmnd_i].downcase)
#         while(arg_i+1 < ARGV.length && !valid_cmnds.include?(ARGV[arg_i+1].downcase))
#             cmnd_hash[ARGV[cmnd_i].downcase].append(ARGV[arg_i+=1])
#         end
#     end
#     arg_i += 1
#     cmnd_i = arg_i
# end
# ARGV.each do |arg|
#     if valid_cmnds.include?(arg.downcase)
#         cmnd_hash[arg] = ""
#     end
# end

# p cmnd_hash

# OptionParser.new do |opt|
#     op.on('')
# end.parse!
