require 'csv'
class MySqliteRequest
    extend Forwardable

    attr_accessor :table, :query, 
    :from_bool, :from_table, 
    :select_bool, :select_columns, 
    :where_bool, :where_columns, :where_criteria, 
    :join_bool, :join_column_db_a, :join_filename_db_b, :join_column_db_b,
    :order_bool, :order_order, :order_column,
    :insert_bool, :insert_table,
    :values_bool, :values_data, 
    :update_bool, :update_table,
    :set_bool, :set_data, 
    :delete_bool, :delete_token



    def initialize()
        @table_list ={}
        @table = []
        @query = []

        # Command bools; set all to false
        @from_bool,@select_bool,@where_bool,
        @join_bool,@order_bool,@insert_bool,
        @values_bool, @set_bool, @delete_bool = false
    end

    def print_query
        return @query
    end    

    def from(table_name)
        @from_bool = true
        @from_table = table_name
        return self
    end

    def self.from(table_name)
        inst = MySqliteRequest.new
        inst.from(table_name)
        return inst
    end

    def from_ex
        @table =  CSV.parse(File.read(@from_table), headers: true).map(&:to_h)
        @query = []
        return self
    end

    def select(*columns)
        @select_bool = true
        @select_columns = columns
        return self
    end

    def self.select(*columns)
        inst = MySqliteRequest.new
        inst.select(*columns)
        return inst
    end

    def select_ex
        columns =  @select_columns.kind_of?(Array)?  @select_columns : [ @select_columns]
        @table.each do |r|
            q_row = {}
            if columns[0] == "*"
                @query << r
            else
                columns.each do |c|
                    q_row[c] = r[c] ? r[c]: ""
                end
                @query << q_row
            end
        end
        return self
    end

    def where(columns, criteria)
        @where_bool = true
        @where_columns  = columns
        @where_criteria = criteria
        return self
    end

    def self.where(columns, criteria)
        inst = MySqliteRequest.new()
        inst.where(columns, criteria)
        return inst
    end

    def where_select_ex
        columns = @where_columns.kind_of?(Array)? @where_columns : [@where_columns]
        criteria = @where_criteria.kind_of?(Array)? @where_criteria : [@where_criteria]
        if columns.length != criteria.length
            p "ERROR"
            return 0
        end
        cc = columns.zip(criteria)
    
        cc.each do |c|
            @query = @query.select {|row| row[c[0]] == c[1]}
        end
        return self
    end

    def join(column_db_a, filename_db_b, column_db_b)
        @join_bool = true
        @join_column_db_a   = column_db_a
        @join_filename_db_b = filename_db_b
        @join_column_db_b   = column_db_b 
        return self
    end

    def self.join(column_db_a, filename_db_b, column_db_b)
        inst = MySqliteRequest.new
        inst.join(column_db_a, filename_db_b, column_db_b)
        return inst
    end

    def join_ex
        t2 = MySqliteRequest.new()
        t2.from(@join_filename_db_b)
        t2.select("*")
        

        # Go through each row of query
        @query.each do |row|
            # Query t2 to get all rows with matching value
            t2q = t2.select("*").where(@join_column_db_b, row[@join_column_db_a]).query
            if t2q.length > 0
                # Assuming there is only one matching row in t2q
                t2q[0].each do |key, value|
                    # Skip if the column is the one being joined on
                    if key == @join_column_db_b
                        next
                    end
                    row[key] = value
                end
            else
                # If nothing found, add columns with nill
                t2.table[0].each do |key, value|
                    row[key] = nil
                end
            end
        end

        return self
    end

    def order(order, column)
        @order_bool = true
        @order_order = order
        @order_column = column
        return self
    end 

    def self.order(order, column)
        inst = MySqliteRequest.new
        inst.order(order, column)
        return inst
    end

    def order_ex
        # Sort- correct for if have nil in column
        if @order_order == :asc 
            @query.sort_by! {|row| row[@order_column]? row[@order_column]: "NA"}
        else
            @query.sort_by! {|row| row[@order_column]? row[@order_column]: "NA" }.reverse!
        end
        return self
    end

    def insert(table_name)
        @insert_bool = true
        @insert_table = table_name
        return self
    end

    def self.insert(table_name)
        inst = MySqliteRequest.new
        inst.insert(table_name)
        return inst
    end

    def insert_ex
        @table_list[@insert_table] = CSV.parse(File.read(@insert_table), headers: true).map(&:to_h)
        return self
    end

    def values(*data)
        @values_bool =true
        @values_data = data.kind_of?(Array)?  data[0] : data
        return self
    end

    def self.values(*data)
        inst = MySqliteRequest.new
        inst.values(data)
        return inst
    end


    def values_ex
        if  @insert_bool
            if !File.exists?(@insert_table)
                headers = @values_data.keys
                CSV.open(@insert_table, "w") do |csv|
                    csv << headers
                end
            else
                headers = CSV.parse(File.read(@insert_table), headers: false).first
            end
            insert_row = []
            headers.each do |col|
                if @values_data.keys.include?(col)
                    insert_row.append(@values_data[col])
                else
                    insert_row.append(nil)
                end
            end
            CSV.open(@insert_table, "a") do |csv|
                csv << insert_row
            end
        else
            p "VALUES command must include an INSERT INTO table"
            return -1
        end
        return self
    end

    def update(table_name)
        @update_bool = true
        @update_table = table_name
        return self
    end

    def self.update(table_name)
        inst = MySqliteRequest.new
        inst.update(table_name)
        return inst
    end

    def set(data)
        @set_bool = true
        @set_data = data
        return self
    end

    def self.set(data)
        inst = MySqliteRequest.new
        inst.set(data)
        return inst
    end

    def set_update_row(row)
        @set_data.each do |key, value|
            row[key] = value
        end
    end

    def set_ex
        data = CSV.parse(File.read(@update_table), headers: false)
        cols = data.first
        crit_idx = cols.find_index(@where_columns)
        data.each do |row|
            if row[crit_idx] == @where_criteria
                @set_data.each do |key,val|
                    row[cols.find_index(key)] = val
                end
            end 
        end
    
        CSV.open(@update_table, "wb") do |csv|
            data.each do |row|
                csv << row
            end
        end
       
    end


    def delete
        @delete_bool = true
        return self
    end

    def self.delete
        inst = MySqliteRequest.new
        inst.delete
        return inst
    end

    def delete_ex
        table = CSV.parse(File.read(@from_table), headers: true)
        n_table = table.select{|row| row[@where_columns]!=@where_criteria}
        CSV.open(@from_table, "wb") do |csv|
            csv << table.first.headers
            n_table.each do |row|
                csv << row
            end
        end

    end

    def run
        # Look for SELECT statements and match with FROM and WHERE
        if @select_bool
            if !@from_bool
                p "a SELECT statement should be associated with a FROM"
                return -1
            else
                self.from_ex
                self.select_ex
                if @where_bool
                    self.where_select_ex
                end
                if @order_bool
                    self.order_ex
                end
                self.print_query
            end 
        elsif @update_bool
            if !@set_bool
                p "a UPDATE statement should be associated with a SET"
                return -1
            else
                self.set_ex
            end
        elsif @insert_bool
            if !@values_bool
                p "a INSERT statement should be associated with a VALUES"
                return -1
            else
                self.values_ex
            end
        elsif @delete_bool
            if !@from_bool
                p "DELETE statement should be associated with a FROM"
                return -1
            end
            if !@where_bool
                p "not including a WHERE clause would delete the entire table!"
                return -1
            end
            self.delete_ex
        end
    end


end