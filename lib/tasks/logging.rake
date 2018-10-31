namespace :logging do
  desc "Outputs a log of all commands run so far"
  task gen_log: :environment do
    all_execs = Execution.all
    stringified = all_execs.map {|e| "#{e.user_name}: #{e.command}"}
    puts "#{all_execs.length} entries follow."
    puts stringified.join "\n"
  end
end
