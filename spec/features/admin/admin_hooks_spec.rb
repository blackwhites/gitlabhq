require 'spec_helper'

describe 'Admin::Hooks' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
  end

  describe 'GET /admin/hooks' do
    it 'is ok' do
      visit admin_root_path

      page.within '.nav-sidebar' do
        click_on 'System Hooks', match: :first
      end

      expect(current_path).to eq(admin_hooks_path)
    end

    it 'has hooks list' do
      system_hook = create(:system_hook)

      visit admin_hooks_path
      expect(page).to have_content(system_hook.url)
    end
  end

  describe 'New Hook' do
    let(:url) { generate(:url) }

    it 'adds new hook' do
      visit admin_hooks_path
      fill_in 'hook_url', with: url
      check 'Enable SSL verification'

      expect { click_button 'Add system hook' }.to change(SystemHook, :count).by(1)
      expect(page).to have_content 'SSL Verification: enabled'
      expect(current_path).to eq(admin_hooks_path)
      expect(page).to have_content(url)
    end
  end

  describe 'Update existing hook' do
    let(:new_url) { generate(:url) }

    before do
      create(:system_hook)
    end

    it 'updates existing hook' do
      visit admin_hooks_path

      click_link 'Edit'
      fill_in 'hook_url', with: new_url
      check 'Enable SSL verification'
      click_button 'Save changes'

      expect(page).to have_content 'SSL Verification: enabled'
      expect(current_path).to eq(admin_hooks_path)
      expect(page).to have_content(new_url)
    end
  end

  describe 'Remove existing hook', :js do
    before do
      create(:system_hook)
    end

    context 'removes existing hook' do
      it 'from hooks list page' do
        visit admin_hooks_path

        expect { accept_confirm { find(:link, 'Remove').send_keys(:return) } }.to change(SystemHook, :count).by(-1)
      end

      it 'from hook edit page' do
        visit admin_hooks_path
        click_link 'Edit'

        expect { accept_confirm { find(:link, 'Remove').send_keys(:return) } }.to change(SystemHook, :count).by(-1)
      end
    end
  end

  describe 'Test', :js do
    before do
      system_hook = create(:system_hook)
      WebMock.stub_request(:post, system_hook.url)
      visit admin_hooks_path

      find('.hook-test-button.dropdown').click
      click_link 'Push events'
    end

    it { expect(current_path).to eq(admin_hooks_path) }
  end

  context 'Merge request hook' do
    describe 'New Hook' do
      let(:url) { generate(:url) }

      it 'adds new hook' do
        visit admin_hooks_path

        fill_in 'hook_url', with: url
        uncheck 'Repository update events'
        check 'Merge request events'

        expect { click_button 'Add system hook' }.to change(SystemHook, :count).by(1)
        expect(current_path).to eq(admin_hooks_path)
        expect(page).to have_content(url)
      end
    end

    describe 'Test', :js do
      before do
        system_hook = create(:system_hook)
        WebMock.stub_request(:post, system_hook.url)
      end

      it 'succeeds if the user has a repository with a merge request' do
        project = create(:project, :repository)
        create(:project_member, user: user, project: project)
        create(:merge_request, source_project: project)

        visit admin_hooks_path
        find('.hook-test-button.dropdown').click
        click_link 'Merge requests events'

        expect(page).to have_content 'Hook executed successfully'
      end
    end
  end
end
