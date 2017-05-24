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

  class ChooseFinalTerms
    include StateMachine::Guard

    def required?(subject)
      !subject.final_terms_selected
    end
  end

  class SignContract
    include StateMachine::Guard

    def required?(subject)
      !subject.signed_contract
    end
  end

  class SignAchAuthorization
    include StateMachine::Guard

    def required?(subject)
      !subject.signed_ach
    end
  end

  class Sign8821
    include StateMachine::Guard

    def required?(subject)
      !subject.signed_8821
    end
  end
end

class Application
  include StateMachine

  attr_accessor :complete, :has_hard_pull, :id_verified, :income_verified, :bank_account_verified,
                :final_terms_selected, :signed_contract, :signed_ach, :signed_8821

  workflow do
    state :incomplete do
      next_state :verification

      event :begin_verification, transitions_to: :verification
      event :decline, transitions_to: :declined
    end
    state :verification do
      next_state :final_terms

      guard :complete_application

      event :finish_verification, transitions_to: :final_terms
      event :decline, transitions_to: :declined
    end
    state :final_terms do
      next_state :final_review

      guard :verify_identity
      guard :verify_income
      guard :verify_bank_account

      event :begin_final_review, transitions_to: :final_review
      event :decline, transitions_to: :declined
    end
    state :final_review do
      next_state :approved

      guard :choose_final_terms
      guard :run_hard_pull

      event :approve, transitions_to: :approved
      event :decline, transitions_to: :declined
    end
    state :approved do
      next_state :complete

      event :complete, transitions_to: :complete
      event :decline, transitions_to: :declined
    end
    state :complete do
      guard :sign_contract
      guard :sign_ach_authorization
      guard :sign_8821
    end
    state :declined
  end

  #################################################################
  #### TODO: MOVE THIS CODE INTO PIPELINES FOR RELEVANT GUARDS ####
  #################################################################
  def complete_application
    puts 'Completing application'
    self.complete = true
  end

  def mark_verified
    puts 'Running verification'
    self.id_verified = true
    self.income_verified = true
    self.bank_account_verified = true
    finish_verification!
  end

  def select_final_terms
    puts 'Selecting final terms'
    self.final_terms_selected = true
    run_hard_pull(true)
  end

  def run_hard_pull(success = [true, false].sample)
    puts 'Running hard pull'
    self.has_hard_pull = true
    success ? begin_final_review! : decline!
  end

  def sign_documents
    puts 'Signing documents'
    self.signed_contract = true
    self.signed_ach = true
    self.signed_8821 = true
    complete!
  end
  #################################################################
  #################################################################

  def on_verification_entry(*)
    puts 'running initial screen, model, soft pull, model'
    decline! if [true, false].sample
  end

  def on_final_terms_entry(*)
    puts "Email customer: Verification is complete. You may now select the final terms for your ISA contract."
  end

  def on_final_review_entry(*)
    puts 'Email rep: Application is ready for approval'
  end

  def on_approved_entry(*)
    puts 'Generating contract for signature'
    puts 'Email customer: Your application has been approved. Please sign your contract to receive your funds!'
  end

  def on_complete_entry(*)
    puts "CONTRACT SIGNED!!!!"
  end
end

a = Application.new
a.complete_application
a.begin_verification!

unless a.declined?
  a.mark_verified
  a.select_final_terms
  a.approve!
  a.sign_documents
end
