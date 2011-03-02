#turn on stacktracing..
Rake.application.options.trace = true

namespace :db do
  # namespace :structure do
  #   desc "Load the database structure from a SQL file"
  #   task :load => :load_config do
  #     abcs = ActiveRecord::Base.configurations
  #     case abcs[Rails.env]["adapter"]
  #     when "mysql", "mysql2", "oci", "oracle"
  #       ActiveRecord::Base.establish_connection(abcs[Rails.env])
  #       ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
  #       IO.readlines("#{Rails.root}/db/#{Rails.env}_structure.sql").join.split("\n\n").each do |table|
  #         ActiveRecord::Base.connection.execute(table)
  #       end
  #     else
  #       raise "Task not supported by '#{abcs[Rails.env]["adapter"]}'"
  #     end
  #   end
  # end
  task :reload do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    # cp "#{Rails.root}/db/ci_structure.sql", "#{Rails.root}/db/#{Rails.env}_structure.sql"
    #     Rake::Task["db:structure:load"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end
  # namespace :redis do
  #   desc "wipe the redis db - Don't ever run this on a production environment"
  #   task :flush do
  #     # raise "CAN'T RUN ON PRODUCTION" if Rails.env.production?
  #     Rake::Task["environment"].invoke
  #     puts "Flushin the redis database"
  #     Activity.redis.flushdb
  #   end
  # end
end
