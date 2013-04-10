module GeeFuHelpers
  def add_genome_build(genome_build, fasta_file, config_file)
    fill_in "Build version (required)", :with => genome_build
    attach_file "Fasta file of sequences (required)", "#{Rails.root}/#{fasta_file}"
    attach_file "YAML file of metadata about this genome (required for AnnoJ browsing only)", "#{Rails.root}/#{config_file}"
    click_button "Create"
  end

  def set_current_user_email(email)
    @current_email = email
  end

  def current_user
    User.where(email: @current_email || current_email_address).first
  end

  def complete_sign_up_form_with(name, email, password="password")
    click_link "Sign up"
    full_name = name.split(" ")
    fill_in "First name", :with => full_name[0]
    fill_in "Last name", :with => full_name[1]
    fill_in "Email address", :with => email
    fill_in "Password", :with => password
    fill_in "Password confirmation", :with => password
  end
end
World(GeeFuHelpers)