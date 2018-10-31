namespace :logging do
  desc "Outputs a log of all commands run so far"
  task gen_log: :environment do
    all_execs = Execution.all
    puts "#{all_execs.length} entries follow."
    puts "========================="
    all_execs.each do |exec|
      puts "user: #{exec.user_name}"
      puts "-------------------------"
      puts exec.command
      puts "========================="
    end
  end
end
