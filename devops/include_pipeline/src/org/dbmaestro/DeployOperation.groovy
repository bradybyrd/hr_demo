package org.dbmaestro;

def upgrade_environment(pipe, env_num){
  def environment = pipe["environments"][env_num]
  def approver = pipe["approvers"][env_num]
  def pair = environment.split(",")
  def do_pair = false
  def version = pipe["version"]
  if(!version.startsWith("V") && version =~ /\d\.\d/) { version = "V${version}" }
  if (pair.size() > 1) {environment = pair[0] }
  do_pair = (pair.size() > 1) 
  if(approver != "none"){
	  input message: "Deploy to ${environment}?", submitter: approver
  }
	echo "#------------------- Performing Deploy on ${environment} --------------#"
	for(env in pair){
		bat "${pipe["java_cmd"]} -Upgrade -ProjectName ${pipe["pipeline"]} -EnvName ${env} -PackageName ${version} -Server ${pipe["server"]} ${pipe["credential"]}"
  }
}

def package_artifacts(pipe, env_num){
  def version = pipe["version"]
  def tasks = pipe["tasks"]
  def base_schema = [pipe["base_schema"]]
  def v_version = version
  if( !version.startsWith("V") && version =~ /\d\.\d/ ) {v_version = "V#{version}" } 
  pair = base_schema[0].split(",")
  if(pair.size() > 1) {base_schema = pair }
  def source_dir = pipe["source_dir"]
  if(!env.Skip_Packaging || env.Skip_Packaging == "No"){
    def icnt = 0
    base_schema.each {schema ->
      def staging_dir = "${pipe["staging_dir"]}${sep()}${pipe["pipeline"]}${sep()}${schema}"
      echo "#------------------- Copying files for ${version} ---------#"
      bat "if exist ${staging_dir} del /q ${staging_dir}${sep()}*"
  		echo "# Cleaning Directory"
  		bat "del /q \"${staging_dir}${sep()}*\""
  		bat "FOR /D %%p IN (\"${staging_dir}${sep()}*.*\") DO rmdir \"%%p\" /s /q"
      def processed_dir = "${source_dir}${sep()}processed${sep()}${v_version}"
      def version_dir = "${staging_dir}${sep()}${v_version}"
      ensure_dir(processed_dir)
      // This is to separate scripts into schema
      def filter = ""
      if(pipe.containsKey("schema_flags")){
        filter = "${pipe[schema_flags[icnt]}*"
      }
      // This is for when files are prefixed with <dbcr_result>
      tasks.split(",").each {item->
        bat "copy \"${source_dir}${sep()}${item.trim()}*${filter}.sql\" \"${version_dir}\""
        bat "move \"${source_dir}${sep()}${item.trim()}*${filter}.sql\" \"${processed_dir}\""
      }
      // This is for copying a whole directory
      //bat "xcopy /s /y /i \"${source_dir}${sep()}${version}\" \"${processed_dir}\""
      icnt += 1
    }
    // trigger packaging
    echo "#----------------- Packaging Files for ${version} -------#"
    bat "${pipe["java_cmd"]} -Package -ProjectName ${pipe["pipeline"]} -Server ${pipe["server"]} ${pipe["credential"]}"
    // version = adhoc_package(version)
  }else{
	  echo "#-------------- Skipping packaging step (parameter set) ---------#"
  }
}

def ensure_dir(pth) {
  folder = new File(pth)
  if ( !folder.exists() ) {
  println "Creating folder: ${pth}"
  folder.mkdirs() }
  return pth
}

def execute(pipe_info, env_num){
  stage(pipe_info["environments"][env_num]){
    node(pipe_info["dbm_node"]){
	  if(env_num == 0){
		  this.package_artifacts(pipe_info, env_num)
	  }
	  this.upgrade_environment(pipe_info, env_num)
    }
  }
}

return this;
