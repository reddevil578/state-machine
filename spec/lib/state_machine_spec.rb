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
      }.to raise_error StateMachine::MissingGuardError
    end
  end

  describe '.workflow_spec' do
    subject { Widget.workflow_spec }
    it { is_expected.to be_a(StateMachine::Specification) }
  end

  describe '.initial_state' do
    subject { Widget.workflow_spec.initial_state.name }
    it { is_expected.to eq :new }
  end

  describe '.next_state_name' do
    subject { Widget.workflow_spec.states[:new].next_state_name }
    it { is_expected.to eq :approved }
  end

  describe '.state_names' do
    subject { Widget.workflow_spec.state_names }
    it { is_expected.to match_array [:new, :approved, :rejected] }
  end

  describe '.events' do
    subject { Widget.workflow_spec.initial_state.events.keys }
    it { is_expected.to match_array [:approve, :reject] }
  end

  describe '.transitions_to' do
    subject { Widget.workflow_spec.states[:new].events[:approve].transitions_to }
    it { is_expected.to eq :approved }
  end

  context 'instance methods' do
    let(:widget) { Widget.new }

    describe '#next_state' do
      subject { widget.next_state.name }
      it { is_expected.to eq :approved }
    end

    describe '#can_move_to_state?' do
      it 'returns true for :rejected state' do
        expect(widget.can_move_to_state?(:rejected)).to be_truthy
      end

      it 'returns false for :approved state' do
        expect(widget.can_move_to_state?(:approved)).to be_falsy
      end
    end

    describe '#can_advance_state?' do
      subject { widget.can_advance_state? }

      context 'when requirements are not met' do
        before { widget.id_verified = false }
        it { is_expected.to be_falsy }
      end

      context 'when requirements are not met' do
        before { widget.id_verified = true }
        it { is_expected.to be_truthy }
      end
    end

    describe '#required_guards' do
      subject { widget.required_guards(:approved).map(&:name) }
      it { is_expected.to match_array [:id_verified] }
    end

    describe '#approve!' do
      context 'with passing guards' do
        before { widget.id_verified = true }

        it 'changes the current_state' do
          expect(widget.current_state.name).to eq :new
          expect(widget.approve!).to eq 'approved'
          expect(widget.current_state.name).to eq :approved
        end
      end

      context 'with failing guards' do
        before { widget.id_verified = false }

        it 'halts the transition' do
          expect(widget.approve!).to be_falsy
          expect(widget.halted_because).to eq 'Guard requirements are not met: [:id_verified]'
        end
      end
    end
  end
end
