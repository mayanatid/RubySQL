require "./my_sqlite_request.rb"


def seed_insert(seed)
    MySqliteRequest.insert('database.csv').values('firstname' => "Thomas_#{seed}", 'lastname' => "Anderson_#{seed}", 'age' => 33, 'password' => 'matrix').run
end


seed_insert(1)
seed_insert(2)
seed_insert(3)

MySqliteRequest.update('database.csv').where('firstname', 'Thomas_2').set('lastname' => 'Anderson_11').run()

seed_insert(1)
seed_insert(2)
seed_insert(3)

MySqliteRequest.from('database.csv').where('firstname', 'Thomas_2').delete().run()