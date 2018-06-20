require 'origen'
class OrigenApbApplication < Origen::Application

  # See http://origen-sdk.org/origen/api/Origen/Application/Configuration.html
  # for a full list of the configuration options available

  # These attributes should never be changed, the duplication here will be resolved in future
  # by condensing these attributes that do similar things
  self.name       = "origen_apb"
  self.namespace  = "OrigenApb"
  config.name     = "origen_apb"
  config.initials = "OrigenApb"
  # Change this to point to the revision control repository for this plugin
  config.rc_url   = "git@github.com:Origen-SDK/origen_apb.git"
  config.release_externally = true

  # To enable deployment of your documentation to a web server (via the 'origen web'
  # command) fill in these attributes.
  config.web_directory = "git@github.com:Origen-SDK/Origen-SDK.github.io.git/origen_apb"
  config.web_domain = "http://origen-sdk.org/origen_apb"

  # See: http://origen-sdk.org/origen/latest/guides/utilities/lint/
  config.lint_test = {
    # Require the lint tests to pass before allowing a release to proceed
    run_on_tag: true,
    # Auto correct violations where possible whenever 'origen lint' is run
    auto_correct: true, 
    # Limit the testing for large legacy applications
    #level: :easy,
    # Run on these directories/files by default
    #files: ["lib", "config/application.rb"],
  }

  config.semantically_version = true

  # Ensure that all tests pass before allowing a release to continue
  def validate_release
    if !system("origen examples") #|| !system("origen specs")
      puts "Sorry but you can't release with failing tests, please fix them and try again."
      exit 1
    else
      puts "All tests passing, proceeding with release process!"
    end
  end

  # Run code coverage when deploying the web site
  def before_deploy_site
    Dir.chdir Origen.root do
      system "origen examples -c"
      dir = "#{Origen.root}/web/output/coverage"       
      FileUtils.remove_dir(dir, true) if File.exists?(dir) 
      system "mv #{Origen.root}/coverage #{dir}"
    end
  end
 
  # Deploy the website automatically after a production tag
  def after_release_email(tag, note, type, selector, options)
    command = "origen web compile --remote --api"
    Dir.chdir Origen.root do
      system command
    end
  end


end
