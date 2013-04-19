module GeeFuHelpers
  def add_genome_build(organism, genome_build, fasta_file, config_file)
    select organism, from: "Organism"
    fill_in "Build version (required)", :with => genome_build
    attach_file "Fasta file of sequences (required)", "#{Rails.root}/#{fasta_file}"
    attach_file "Yaml file of metadata about this genome", "#{Rails.root}/#{config_file}"
    click_button "Create"
  end

  def add_experiment(name, description, gff_file, genome_build)
    within "div#gff_experiment_data" do
      fill_in("name (required)", :with => name)
      fill_in("description (required)", :with => description)
      attach_file("GFF3 file of features (required)", "#{Rails.root}/#{gff_file}")
      choose(genome_build)
      click_button "Create"
    end
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