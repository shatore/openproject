#-- encoding: UTF-8

#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe WorkPackage, 'custom_actions', type: :model do
  let(:work_package) do
    FactoryGirl.build_stubbed(:stubbed_work_package,
                              project: project)
  end
  let(:project) { FactoryGirl.create(:project) }
  let(:status) { FactoryGirl.create(:status) }
  let(:other_status) { FactoryGirl.create(:status) }
  let(:user) do
    FactoryGirl.create(:user,
                       member_in_project: work_package.project,
                       member_through_role: role)
  end
  let(:role) do
    FactoryGirl.create(:role)
  end
  let(:conditions) do
    [CustomActions::Conditions::Status.new([status.id])]
  end

  let!(:custom_action) do
    action = FactoryGirl.build(:custom_action)
    action.conditions = conditions

    action.save!
    action
  end

  describe '#custom_actions' do
    context 'with the custom action having no restriction' do
      let(:conditions) do
        []
      end

      before do
        work_package.status_id = status.id
      end

      it 'returns the action' do
        expect(work_package.custom_actions(user))
          .to match_array [custom_action]
      end
    end

    context 'with a status restriction' do
      context 'with the work package having the same status' do
        before do
          work_package.status_id = status.id
        end

        it 'returns the action' do
          expect(work_package.custom_actions(user))
            .to match_array [custom_action]
        end
      end

      context 'with the work package having a different status' do
        before do
          work_package.status_id = other_status.id
        end

        it 'does not return the action' do
          expect(work_package.custom_actions(user))
            .to be_empty
        end
      end
    end

    context 'with a role restriction' do
      let(:conditions) do
        [CustomActions::Conditions::Role.new(role.id)]
      end

      context 'with the user having the same role' do
        it 'returns the action' do
          expect(work_package.custom_actions(user))
            .to match_array [custom_action]
        end
      end

      context 'with the condition requiring a different role' do
        let(:other_role) { FactoryGirl.create(:role) }

        let(:conditions) do
          [CustomActions::Conditions::Role.new(other_role.id)]
        end

        it 'does not return the action' do
          expect(work_package.custom_actions(user))
            .to be_empty
        end
      end
    end
  end
end
