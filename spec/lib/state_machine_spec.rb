require 'spec_helper'

RSpec.describe StateMachine do
  context 'with missing transitions_to' do
    it 'immediately raises a WorkflowDefinitionError' do
      expect {
        require './spec/support/error_cases/missing_transition'
      }.to raise_error StateMachine::WorkflowDefinitionError
    end
  end

  context 'with missing guard policy' do
    it 'immediately raises a MissingPolicyError' do
      expect {
        require './spec/support/error_cases/missing_guard_policy'
      }.to raise_error StateMachine::MissingPolicyError
    end
  end

  context 'with valid workflow definition' do
    it 'creates a workflow_spec' do
      expect(Widget.workflow_spec).to be_a(StateMachine::Specification)
    end

    it 'has the correct initial state' do
      expect(Widget.workflow_spec.initial_state.name).to eq :new
    end

    it 'has the correct states' do
      expect(Widget.workflow_spec.state_names).to \
        match_array [:new, :approved, :rejected]
    end

    it 'has the correct events' do
      expect(Widget.workflow_spec.initial_state.events.keys).to \
        match_array [:approve, :reject]
    end

    it 'sets :transitions_to on the event correctly' do
      expect(Widget.workflow_spec.states[:new].events[:approve].transitions_to).to \
        eq :approved
    end

    context 'an individual Widget' do
      let(:widget) { Widget.new }

      it 'has the correct next_state' do
        expect(widget.next_state.name).to eq :approved
      end

      it 'uses the provided policy to check can_advance_state?' do
        widget.id_verified = false
        expect(widget.can_advance_state?).to be_falsy
        widget.id_verified = true
        expect(widget.can_advance_state?).to be_truthy
      end

      it 'correctly calculates can_move_to_state' do
        expect(widget.can_move_to_state?(:approved)).to be_falsy
        expect(widget.can_move_to_state?(:rejected)).to be_truthy
      end

      it 'returns the correct required_guards' do
        expect(widget.required_guards(:approved).map(&:name)).to eq [:id_verified]
      end
    end
  end
end
