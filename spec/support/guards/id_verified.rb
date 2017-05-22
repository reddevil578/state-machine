module StateMachine
  class IdVerified
    include StateMachine::Guard

    def required?(subject)
      !subject.id_verified?
    end

    def on_complete
      puts "ID VERIFICATION IS COMPLETE"
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
end
