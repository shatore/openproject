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
require_relative '../shared_expectations'

describe CustomActions::Actions::AssignedTo, type: :model do
  it_behaves_like 'associated custom action' do
    let(:key) { :assigned_to }

    describe '#allowed_values' do
      context 'group assignment disabled', with_settings: { work_package_group_assignment?: false } do
        it 'is the list of all users' do
          users = [FactoryGirl.build_stubbed(:user),
                   FactoryGirl.build_stubbed(:user)]
          allow(User)
            .to receive_message_chain(:active_or_registered, :select, :order_by_name)
            .and_return(users)

          expect(instance.allowed_values)
            .to eql([{ value: nil, label: '-' },
                     { value: users.first.id, label: users.first.name },
                     { value: users.last.id, label: users.last.name }])
        end
      end

      context 'group assignment enabled', with_settings: { work_package_group_assignment?: true } do
        it 'is the list of all users' do
          users = [FactoryGirl.build_stubbed(:user),
                   FactoryGirl.build_stubbed(:group)]
          allow(Principal)
            .to receive_message_chain(:active_or_registered, :select, :order_by_name)
            .and_return(users)

          expect(instance.allowed_values)
            .to eql([{ value: nil, label: '-' },
                     { value: users.first.id, label: users.first.name },
                     { value: users.last.id, label: users.last.name }])
        end
      end
    end
  end
end
