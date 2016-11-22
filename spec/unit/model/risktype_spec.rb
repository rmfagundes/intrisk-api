require_relative '../../../models/riskmanagement/risktype'
describe Models::RiskManagement::RiskType do
  class RiskTypeMock < Models::RiskManagement::RiskType
    def wflow_engine
      wflow_file = 'conf/workflow/riskmanagement/risktype.yml'
      @wflow = WorkflowMock.new(wflow_file) if @wflow.nil?
    end

    def destroy
    end

    def save
    end

    class WorkflowMock < Modules::Workflow
      def notify(model, msg_config)
      end
    end
  end

  it 'initial_state' do
    example = RiskTypeMock.new
    params = { 'name' => 'TEST', 'language' => 'en' }
    example.build_attributes(params)
    example.insert
    expect(example.status).to eq('ACTIVE')
  end

  it 'status_change' do
    example = RiskTypeMock.new
    params = { 'status' => 'ACTIVE' }
    example.build_attributes(params)
    example.remove
    expect(example.status).to eq('REMOVED')
  end

  it 'policy_check_invalid_object' do
    example = RiskTypeMock.new
    expect { example.insert }
      .to raise_error(PolicyException,
                      '["Name required", "Language required"]')
  end
end
