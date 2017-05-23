require './lib/state_machine'

module StateMachine
  class CompleteApplication
    include StateMachine::Guard

    def required?(subject)
      !subject.complete
    end
  end

  class RunHardPull
    include StateMachine::Guard

    def required?(subject)
      !subject.has_hard_pull
    end
  end

  class VerifyIdentity
    include StateMachine::Guard

    def required?(subject)
      !subject.id_verified
    end

    pipelines do
      pipeline :blockscore do
        workflow :answer_kbas
      end
      pipeline :drivers_license do
        workflow :document_request, document_type: :drivers_license
        workflow :verify_identity
      end
    end
  end

  class VerifyIncome
    include StateMachine::Guard

    def required?(subject)
      !subject.income_verified
    end
  end

  class VerifyBankAccount
    include StateMachine::Guard

    def required?(subject)
      !subject.bank_account_verified
    end
  end
end

class Application
  include StateMachine

  attr_accessor :complete, :has_hard_pull, :id_verified, :income_verified, :bank_account_verified

  workflow do
    state :incomplete do
      next_state :in_verification

      event :begin_verification, transitions_to: :in_verification
    end
    state :in_verification do
      next_state :final_terms

      guard :complete_application

      event :finish_verification, transitions_to: :final_terms
    end
    state :final_terms do
      next_state :approved

      guard :verify_identity
      guard :verify_income
      guard :verify_bank_account

      event :approve, transitions_to: :approved
    end
    state :approved do
      next_state :won

      event :mark_won, transitions_to: :won
    end
    state :won do
      guard :run_hard_pull
    end
  end

  def on_final_terms_entry(*)
    puts "Email customer: Verification is complete. You may now select the final terms for your ISA contract."
  end

  def on_approved_entry(*)
    puts "generating contract for signature"
  end

  def on_won_entry(*)
    puts "CONTRACT SIGNED!!!!"
  end
end
