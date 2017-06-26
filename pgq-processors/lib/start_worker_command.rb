require File.expand_path('../../pgq_env', __FILE__)

class StartWorkerCommand
  def initialize(config_path, db_config_path)
    @config_path    = config_path
    @db_config_path = db_config_path
  end

  def execute
    return false unless FileTest.exist?(@config_path)

    dbconfig  = YAML.load(File.read(@db_config_path))
    sysconfig = YAML.load(File.read(@config_path))

    config = dbconfig.merge(sysconfig)
    pgq_env = PgqEnv.new(config)

    w = Pgq::Worker.new(pgq_env)

    pid_file =  pgq_env.config["pid_file"]
    raise "Please setup pid_file in config_file" if pid_file.blank?
    raise 'pid file exists!' if File.exists? pid_file
    File.open(pid_file, 'w'){|f| f.puts Process.pid}
    begin
      w.run
    ensure
      File.delete pid_file
    end
  end
end
