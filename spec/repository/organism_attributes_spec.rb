require 'spec_helper'

describe OrganismAttributes do

  describe "#name" do
    context "when we have a full complement of attributes" do
      let(:organism) { mock(Organism, :genus => "Arabidopsis", :species => "thaliana", :strain => "Col 0", :taxid => "3702") }
      subject { OrganismAttributes.new(organism) }
      
      it "is the taxid_genus_species_strain" do
        subject.combine.should eq "3702_Arabidopsis_thaliana_Col 0"
      end
    end

    context "when we are missing a taxid" do
      let(:organism) { mock(Organism, :genus => "Arabidopsis", :species => "thaliana", :strain => "Col 0", :taxid => nil) }
      subject { OrganismAttributes.new(organism) }
      
      it "is the no-ncbi-taxid_genus_species_strain" do
        subject.combine.should eq "no-ncbi-taxid_Arabidopsis_thaliana_Col 0"
      end
    end

    context "when we are missing a strain" do
      let(:organism) { mock(Organism, :genus => "Arabidopsis", :species => "thaliana", :strain => nil, :taxid  => "3702") }
      subject { OrganismAttributes.new(organism) }
      
      it "is the taxid_genus_species_no-strain" do
        subject.combine.should eq "3702_Arabidopsis_thaliana_no-strain"
      end
    end

    context "when we are missing both taxid and strain" do
      let(:organism) { mock(Organism, :genus => "Arabidopsis", :species => "thaliana", :strain => nil, :taxid  => nil) }
      subject { OrganismAttributes.new(organism) }
      
      it "is the no-ncbi-taxid_genus_species_no-strain" do
        subject.combine.should eq "no-ncbi-taxid_Arabidopsis_thaliana_no-strain"
      end
    end
  end
end