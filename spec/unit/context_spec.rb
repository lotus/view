# frozen_string_literal: true

require "dry/effects"
require "hanami/view/context"
require "hanami/view/part"
require "hanami/view/part_builder"
require "hanami/view/scope_builder"

RSpec.describe Hanami::View::Context do
  include Dry::Effects::Handler.Reader(:render_env)

  let(:context_class) {
    Class.new(Hanami::View::Context) do
      attr_reader :assets, :routes

      decorate :assets
      decorate :invalid_attribute

      def initialize(assets:, routes:, **args)
        super(**args)
        @assets = assets
        @routes = routes
      end
    end
  }

  let(:assets) { double(:assets) }
  let(:routes) { double(:routes) }

  let(:render_env) {
    Hanami::View::RenderEnvironment.new(
      inflector: Dry::Inflector.new,
      renderer: double(:renderer),
      context: context,
      part_builder: Hanami::View::PartBuilder.new,
      scope_builder: Hanami::View::ScopeBuilder.new
    )
  }

  subject(:context) { context_class.new(assets: assets, routes: routes) }

  around do |example|
    with_render_env(render_env) do
      example.run
    end
  end

  it "provides attributes decorated in view parts" do
    expect(context.assets).to be_a Hanami::View::Part
    expect(context.assets.value).to eql assets
  end
end
