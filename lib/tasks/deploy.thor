require './config/environment.rb'

class Deploy < Thor
  desc "local_to_remote", "Deploy <local branch> to <remote server>"
  def local_to_remote(local_branch, remote_server)
    return unless run_system("git checkout #{local_branch}")
    return unless run_system("git pull origin #{local_branch}")
    git_status = `git status`
    puts git_status
    return unless git_status == "# On branch #{local_branch}\nnothing to commit (working directory clean)\n"

    return unless run_system("git checkout #{remote_server}")
    return unless run_system("git reset #{local_branch} --hard")
    return unless run_system("git push origin #{remote_server} -f")
    return unless run_system("git push #{remote_server} #{local_branch}:master -f")
    return unless run_system("git checkout master")
  end

  private

  def run_system(command)
    puts "$ #{command}"
    result = `#{command}`
    if $?.success?
      puts result
      true
    else
      puts result
      false
    end
  end
end
