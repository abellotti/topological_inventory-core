describe "ActsAsTaggableOn" do
  let(:tenant) { Tenant.find_or_create_by!(:name => "default", :external_tenant => "external_tenant_uuid") }
  let(:source_type) { SourceType.find_or_create_by!(:name => 'openshift', :product_name => "OpenShift", :vendor => "Red Hat") }
  let(:source) { Source.find_or_create_by!(:name => "OCP", :uid => "9a874712-9a55-49ab-a46a-c823acc35503", :tenant => tenant, :source_type => source_type) }
  let(:container_image) { ContainerImage.find_or_create_by!(:tenant => tenant, :source_ref => "XXX", :source => source) }

  context "common tagging operations" do
    describe ".taggable?" do
      it "returns true" do
        expect(container_image.class.taggable?).to be_truthy
      end
    end

    describe "#tagged_with?" do
      it "returns true if objects is tagged" do
        container_image.tag_add("awesome")

        expect(container_image.tagged_with?("awesome")).to be_truthy
        expect(container_image.tagged_with?("XXXX")).to be_falsey
      end
    end

    describe "#tag_add" do
      it "tags an object with a single tag" do
        container_image.tag_add("awesome")
        expect(container_image.tag_list).to eq(["awesome"])
        expect(container_image.tags.pluck(:name, :namespace, :value)).to eq([["awesome", "", ""]])
      end

      it "tags an object with tags" do
        container_image.tag_add(%w[awesome cool])

        expect(container_image.tags.map(&:name)).to eq(%w[awesome cool])
      end

      it "tags an object with single tag and with namespace and value" do
        container_image.tag_add("awesome", :namespace => "cyberspace", :value => "awesomeness")
        expect(container_image.tags.pluck(:name, :namespace, :value)).to eq([%w[awesome cyberspace awesomeness]])
      end

      it "does not add same tag twice" do
        expect(container_image.tags.count).to eq(0)
        container_image.tag_add("awesome")
        expect(container_image.tags.count).to eq(1)

        container_image.tag_add("awesome")
        expect(container_image.tags.count).to eq(1)

        container_image.tag_add("awesome", :namespace => "cyberspace", :value => "awesomeness")
        expect(container_image.tags.count).to eq(2)
        container_image.tag_add("awesome", :namespace => "cyberspace", :value => "awesomeness")
        expect(container_image.tags.count).to eq(2)
      end
    end

    describe "#tag_list" do
      it "lists tags add to object" do
        container_image.tag_add(%w[awesome cool])

        expect(container_image.tag_list).to eq(%w[awesome cool])
      end
    end

    describe "#tag_remove" do
      it "removes tag from object" do
        container_image.tag_add(%w[awesome cool])

        expect(container_image.tags.count).to eq(2)

        expect(Tag.count).to eq(2)
        expect(ContainerImageTag.count).to eq(2)
        container_image.tag_remove("awesome")
        expect(container_image.tags.count).to eq(1)

        expect(container_image.tag_list).to eq(%w[cool])
        expect(Tag.count).to eq(1)
        expect(ContainerImageTag.count).to eq(1)
      end

      it "removes tag from object" do
        container_image.tag_add(%w[awesome cool])

        expect(container_image.tags.count).to eq(2)

        expect(Tag.count).to eq(2)
        expect(ContainerImageTag.count).to eq(2)
        container_image.tag_remove(%w[awesome cool])
        expect(container_image.tags.count).to eq(0)
        expect(Tag.count).to eq(0)
        expect(ContainerImageTag.count).to eq(0)
      end

      it "removes tag with namespace and value from object" do
        container_image.tag_add("cool", :namespace => "cyberspace", :value => "awesomeness")
        expect(container_image.tags.count).to eq(1)

        expect(Tag.count).to eq(1)
        expect(ContainerImageTag.count).to eq(1)
        container_image.tag_remove("cool", :namespace => "cyberspace", :value => "awesomeness")
        expect(container_image.tags.count).to eq(0)
        expect(Tag.count).to eq(0)
        expect(ContainerImageTag.count).to eq(0)
      end

      it "removes tags" do
        container_image.tag_add(%w[awesome cool])
        expect(container_image.tags.count).to eq(2)

        expect(Tag.count).to eq(2)
        expect(ContainerImageTag.count).to eq(2)
        container_image.tag_remove(%w[awesome cool])
        expect(container_image.tags.count).to eq(0)
        expect(Tag.count).to eq(0)
        expect(ContainerImageTag.count).to eq(0)
      end

      it "removes tags with namespace and value from object" do
        container_image.tag_add(%w[awesome cool])
        expect(container_image.tags.count).to eq(2)
        container_image.tag_add("cool", :namespace => "cyberspace", :value => "awesomeness")
        expect(container_image.tags.count).to eq(3)

        expect(Tag.count).to eq(3)
        expect(ContainerImageTag.count).to eq(3)
        container_image.tag_remove(%w[awesome cool])
        expect(container_image.tags.count).to eq(1)
        expect(container_image.tags.pluck(:name, :namespace, :value)).to eq([%w[cool cyberspace awesomeness]])
        expect(Tag.count).to eq(1)
        expect(ContainerImageTag.count).to eq(1)
      end
    end

    describe "#tagged_with" do
      let(:container_image_other) { ContainerImage.find_or_create_by!(:tenant => tenant, :source_ref => "YYY", :source => source) }

      it "finds tagged container images" do
        container_image.tag_add(%w[awesome cool])
        container_image_other.tag_add(%w[super])

        expect(ContainerImage.tagged_with("awesome").take.id).to eq(container_image.id)
        expect(ContainerImage.tagged_with("cool").take.id).to eq(container_image.id)
        expect(ContainerImage.tagged_with("super").take.id).to eq(container_image_other.id)
      end
    end
  end
end
