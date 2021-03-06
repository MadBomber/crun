module Crun
  SHARDS_START_ANCHOR = \
     Regex.escape(ENV.fetch("CRUN_SHARDS_START_ANCHOR", "---"))
  SHARDS_END_ANCHOR = \
     Regex.escape(ENV.fetch("CRUN_SHARDS_END_ANCHOR", "..."))

  @@shards_yaml : String | Nil

  private SHARDS_YAML_REGEX = \
     /^# #{SHARDS_START_ANCHOR}\n(.+)# #{SHARDS_END_ANCHOR}$/m

  def self.shards_yaml
    @@shards_yaml ||= (
      File.read(SOURCE)
        .match(SHARDS_YAML_REGEX)
        .try { |md| md[1]? }
        .try { |text| text.gsub(/^# /m, "    ") }
    )
  end

  def self.build_shards_config
    File.open(File.join(build_dir, "shard.yml"), "w") do |file|
      file.puts <<-EOYAML
      ---
      name: #{SOURCE_FILENAME}
      version: 0.1.0
      dependencies:
      #{shards_yaml}
      ...
      EOYAML
    end
  end
end
