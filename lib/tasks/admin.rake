namespace :admin do
  desc "Set as admin (requires email)"
  task :set => [:environment] do |t, args|
    update_admin_user(true)
  end

  desc "Remove as admin (requires email)"
  task :remove => [:environment] do |t, args|
    update_admin_user(false)
  end

  def update_admin_user(value)
    task_name = value ? "set" : "remove"
    email     = ENV['email']
    abort "\n*** Please provide an email, e.g. rake admin:#{task_name} email=me@example.com ***" unless email.present?

    if(value)
      boolval = '-a'
    else
      boolval = '-r -w'  
    end

    `#{WebApolloPath}/tools/user/set_track_permissions.pl -D #{WebApolloDatabase} -U #{WebApolloDatabaseUsername} -P #{WebApolloDatabasePassword} #{boolval} -u #{email} -t #{WebApolloPath}/data/scratch/seqids.txt  > /dev/null`

    user = User.where(email: email).first
    abort "\n*** No user found with email: #{email} ***" unless user.present?
    user.update_attributes(admin: value)

    puts "\n*** SUCCESS: admin #{task_name} on #{email} ***"
  end
end
