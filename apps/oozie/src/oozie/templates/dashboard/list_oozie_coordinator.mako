## -*- coding: utf-8 -*-
## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
  from desktop.views import commonheader, commonfooter
  from django.utils.translation import ugettext as _
  
  from oozie.conf import ENABLE_V2
%>

<%namespace name="layout" file="../navigation-bar.mako" />
<%namespace name="utils" file="../utils.inc.mako" />

${ commonheader(_("Coordinator Dashboard"), "oozie", user) | n,unicode }
${ layout.menubar(section='coordinators', dashboard=True) }

<link rel="stylesheet" href="${ static('oozie/css/coordinator.css') }" type="text/css" />

<div class="container-fluid">
  <div class="card card-small">
    <div class="card-body">

      <div class="row-fluid">
        <div class="span2">
          <div class="sidebar-nav">
            <ul class="nav nav-list" style="border:none">
              <li class="nav-header">${ _('Coordinator') }</li>
              % if coordinator is not None:
              <li><a href="${ coordinator.get_absolute_url() }">${ oozie_coordinator.appName }</a></li>
              % else:
              <li class="white">${ oozie_coordinator.appName }</li>
              % endif

              <li class="nav-header">${ _('Submitter') }</li>
              <li class="white">${ oozie_coordinator.user }</li>

              <li class="nav-header">${ _('Status') }</li>
              <li class="white" id="status"><span class="label ${ utils.get_status(oozie_coordinator.status) }">${ oozie_coordinator.status }</span></li>

              <li class="nav-header">${ _('Progress') }</li>
              <li class="white" id="progress">
                <div class="progress">
                  <div class="bar" style="width: 0">${ oozie_coordinator.get_progress() }%</div>
                </div>
              </li>

              <li class="nav-header">${ _('Frequency') }</li>
              % if enable_cron_scheduling:
                <li class="white cron-frequency">${ oozie_coordinator.human_frequency }</li>
              % else:
                <li class="white">${ oozie_coordinator.frequency } ${ oozie_coordinator.timeUnit }</li>
              % endif

              <li class="nav-header">${ _('Next Materialized Time') }</li>
              <li class="white" id="nextTime">${ utils.format_time(oozie_coordinator.nextMaterializedTime) }</li>

              <li class="nav-header">${ _('Id') }</li>
              <li class="white">${ oozie_coordinator.id }</li>

              % if coordinator:
              % if ENABLE_V2.get():
                  <li class="nav-header">${ _('Datasets') }</li>
                % for dataset in coordinator.datasets:
                  <li rel="tooltip" title="${ dataset.data['dataset_variable'] }" class="white">
                    <i class="fa fa-eye"></i> <span class="dataset">${ dataset.data['workflow_variable'][:20] }</span>
                  </li>
                % endfor
                % if not coordinator.datasets:
                  <li class="white">${ _('No available datasets') }</li>
                % endif
              % else:
                  <li class="nav-header">${ _('Datasets') }</li>
                % for dataset in coordinator.dataset_set.all():
                  <li rel="tooltip" title="${ dataset.name } : ${ dataset.uri }" class="white"><i class="fa fa-eye"></i> <span class="dataset">${ dataset.name }</span></li>
                % endfor
                % if not coordinator.dataset_set.all():
                  <li class="white">${ _('No available datasets') }</li>
                % endif
              % endif
              % endif

              % if has_job_edition_permission(oozie_coordinator, user) and oozie_coordinator.status not in ('KILLED', 'SUCCEEDED'):
                <li class="nav-header">${ _('Manage') }</li>
                <li class="white">
                  <div id="rerun-coord-modal" class="modal hide"></div>
                  <button title="${ _('Suspend the coordinator after finishing the current running actions') }" id="suspend-btn"
                     data-url="${ url('oozie:manage_oozie_jobs', job_id=oozie_coordinator.id, action='suspend') }"
                     data-confirmation-header="${ _('Are you sure you want to suspend this job?') }"
                     data-confirmation-footer="normal"
                     class="btn btn-small confirmationModal
                     % if not oozie_coordinator.is_running():
                       hide
                     % endif
                     " rel="tooltip" data-placement="right" style="margin-bottom: 5px">
                    ${ _('Suspend') }
                  </button>
                  <button title="${ _('Resume the coordinator') }" id="resume-btn"
                     data-url="${ url('oozie:manage_oozie_jobs', job_id=oozie_coordinator.id, action='resume') }"
                     data-confirmation-header="${ _('Are you sure you want to resume this job?') }"
                     data-confirmation-footer="normal"
                     class="btn btn-small confirmationModal
                     % if oozie_coordinator.is_running():
                       hide
                     % endif
                     " style="margin-bottom: 5px">
                    ${ _('Resume') }
                  </button>
                  <button title="${ _('Edit End Time') }" id="edit-endtime-btn"
                     data-url="${ url('oozie:manage_oozie_jobs', job_id=oozie_coordinator.id, action='change') }"
                     data-confirmation-header="${ _('Update End Time') }"
                     data-confirmation-footer="update"
                     class="btn btn-small confirmationModal
                     % if not oozie_coordinator.is_running():
                       hide
                     % endif
                     " style="margin-bottom: 5px">
                    ${ _('Edit') }
                  </button>
                  <br/>
                  <button title="${_('Kill %(coordinator)s') % dict(coordinator=oozie_coordinator.id)}"
                   id="kill-btn"
                    class="btn btn-small btn-danger disable-feedback confirmationModal
                     % if not oozie_coordinator.is_running():
                       hide
                     % endif
                    "
                    alt="${ _('Are you sure you want to kill coordinator %s?') % oozie_coordinator.id }"
                    href="javascript:void(0)"
                    data-url="${ url('oozie:manage_oozie_jobs', job_id=oozie_coordinator.id, action='kill') }"
                    data-message="${ _('The coordinator was killed!') }"
                    data-confirmation-footer="danger"
                    data-confirmation-header="${ _('Are you sure you want to kill this job?') }" style="margin-bottom: 5px">
                      ${_('Kill')}
                  </button>
                </li>
              % endif
            </ul>
          </div>
        </div>
        <div class="span10">
          <h1 class="card-heading simple card-heading-nopadding card-heading-noborder card-heading-blue" style="margin-bottom: 10px">
            % if oozie_bundle:
              ${ _('Bundle') } <a href="${ oozie_bundle.get_absolute_url() }">${ oozie_bundle.appName }</a> :
            % endif
            ${ _('Coordinator') } ${ oozie_coordinator.appName }
          </h1>

          <ul class="nav nav-tabs">
            <li class="active"><a href="#calendar" data-toggle="tab">${ _('Calendar') }</a></li>
            <li><a href="#actions" data-toggle="tab">${ _('Actions') }</a></li>
            <li><a href="#details" data-toggle="tab">${ _('Details') }</a></li>
            <li><a href="#configuration" data-toggle="tab">${ _('Configuration') }</a></li>
            <li><a href="#log" data-toggle="tab">${ _('Log') }</a></li>
            <li><a href="#definition" data-toggle="tab">${ _('Definition') }</a></li>
            % if oozie_coordinator.has_sla:
            <li><a href="#sla" data-toggle="tab">${ _('SLA') }</a></li>
            % endif
          </ul>

          <div class="tab-content" style="min-height:200px">
            <div class="tab-pane active" id="calendar">
              <div class="pull-left">
                <input type="text" data-bind="textInput: searchFilter, value: searchFilter,  valueUpdate: 'input'" class="input-xlarge search-query" placeholder="${_('Filter results')}">
                % if has_job_edition_permission(oozie_coordinator, user):
                    <div id="coord-actions" data-bind="enable: selectedActions().length > 0" class="btn-group" style="vertical-align: middle">
                      <button data-bind="enable: selectedActions().length > 0" class="btn btn-primary rerun-btn"
                         % if oozie_coordinator.is_running() or oozie_coordinator.status in ('KILLED', 'FAILED'):
                           disabled="disabled"
                         % endif
                        data-rerun-url="${ url('oozie:rerun_oozie_coord', job_id=oozie_coordinator.id, app_path=oozie_coordinator.coordJobPath) }">
                        <i class="fa fa-refresh"></i> ${ _('Rerun') }
                      </button>
                      <button id="trash-btn-caret" class="btn toolbarBtn dropdown-toggle" data-toggle="dropdown"
                        data-bind="enable: selectedActions().length > 0">
                        <span class="caret"></span>
                      </button>
                      <ul class="dropdown-menu"> <li data-bind="enable: selectedActions().length > 0">
                          <a href='#' class="ignore-btn confirmationModal" data-url="${ url('oozie:manage_oozie_jobs', job_id=oozie_coordinator.id, action='ignore') }"
                              data-confirmation-body="${ _('Are you sure you want to ignore the action(s)?')}"
                              data-confirmation-footer="normal"
                              data-confirmation-header="${ _('Note: You can only ignore a FAILED, KILLED or TIMEDOUT action' )}" > ${ _('Ignore') } </a></li>
                      </ul>
                    </div>
                % endif
              </div>
              <div class="btn-group pull-right" style="margin-right: 20px">
                <a class="btn btn-status btn-success" data-table="calendar" data-value="SUCCEEDED">${ _('Succeeded') }</a>
                <a class="btn btn-status btn-warning" data-table="calendar" data-value="RUNNING">${ _('Running') }</a>
                <a class="btn btn-status btn-danger disable-feedback" data-table="calendar" data-value="ERROR">${ _('Error') }</a>
              </div>
              <div class="clearfix"></div>

              <table class="table table-striped table-condensed margin-top-10">
                <thead>
                <tr>
                  <th width="20"><div data-bind="click: selectAll, css: { 'fa-check': allSelected }" class="hueCheckbox fa"></div></th>
                  <th width="200">${ _('Day') }</th>
                  <th>${ _('Comment') }</th>
                </tr>
                </thead>
                <tbody data-bind="template: { name: 'calendarTemplate', foreach: filteredActions}" >
                </tbody>
                <tfoot>
                  <tr data-bind="visible: isLoading()">
                    <td colspan="2" class="left">
                      <img src="${ static('desktop/art/spinner.gif') }" />
                    </td>
                  </tr>
                  <tr data-bind="visible: filteredActions().length == 0 && !isLoading()">
                    <td colspan="3">
                      <div class="alert">
                        ${ _('There are no actions to be shown.') }
                      </div>
                    </td>
                  </tr>
                </tfoot>
              </table>

              <div class="pagination dataTables_paginate">
                <ul>
                  <li class="prev"><a href="javascript:void(0)" class="btn-actions-pagination" data-value="prev" data-table="calendar"><i class="fa fa-long-arrow-left"></i> ${ _('Previous') }</a></li>
                  <li class="next"><a href="javascript:void(0)" class="btn-actions-pagination" data-value="next" data-table="calendar">${ _('Next') } <i class="fa fa-long-arrow-right"></i></a></li>
                </ul>
              </div>
            </div>

            <script id="calendarTemplate" type="text/html">
              <tr data-bind="css: { disabled: url == '' }">
                <td data-bind="click: handleSelect"><div data-bind="css: { 'fa-check': selected }" class="hueCheckbox fa"></div></td>
                <td data-bind="css: { disabled: url == '' }">
                  <a data-bind="attr: {href: url != '' ? url : 'javascript:void(0)', title: url ? '' : '${ _('Workflow not available or instantiated yet') }' }, css: { disabled: url == '' }" data-row-selector="true">
                    <span data-bind="text: title, attr: {'class': statusClass, 'id': 'date-' + $index()}"></span>
                  </a>
                </td>
                <td data-bind="css: { disabled: url == '' }"><em data-bind="visible: (errorMessage == null || errorMessage == '') && (missingDependencies == null || missingDependencies == '') && url == ''">${ _('Workflow not available or instantiated yet') }</em><em data-bind="visible: (errorMessage == null || errorMessage == '') && (missingDependencies == null || missingDependencies == '') && url != ''">${_('-')}</em> <span data-bind="visible: errorMessage != null && errorMessage != '', text: errorMessage"></span> <span data-bind="visible:missingDependencies !='' && missingDependencies != null, text: '${ _('Missing')} ' + missingDependencies"></span></td>
              </tr>
            </script>


            <div class="tab-pane" id="actions">
              <div class="pull-left">
                <input type="text" data-bind="textInput: searchFilter, value: searchFilter,  valueUpdate: 'input'" class="input-xlarge search-query" placeholder="${_('Filter results')}">
              </div>
              <div class="btn-group pull-right" style="margin-right: 20px;">
                <a class="btn btn-status btn-success" data-table="actions" data-value="SUCCEEDED">${ _('Succeeded') }</a>
                <a class="btn btn-status btn-warning" data-table="actions" data-value="RUNNING">${ _('Running') }</a>
                <a class="btn btn-status btn-danger disable-feedback" data-table="actions" data-value="ERROR">${ _('Error') }</a>
              </div>
              <div class="clearfix"></div>
              <table class="table table-striped table-condensed margin-top-10" cellpadding="0" cellspacing="0">
                <thead>
                <tr>
                  <th width="1%">${ _('Number') }</th>
                  <th width="14%">${ _('Nominal Time') }</th>

                  <th width="5%">${ _('Type') }</th>
                  <th width="5%">${ _('Status') }</th>

                  <th width="5%">${ _('Error Code') }</th>
                  <th width="14%">${ _('Error Message') }</th>
                  <th width="10%">${ _('Missing Dependencies') }</th>

                  <th width="10%">${ _('Created Time') }</th>
                  <th width="10%">${ _('Last Modified') }</th>

                  <th width="13%">${ _('Id') }</th>
                  <th width="13%">${ _('External Id') }</th>
                </tr>
                </thead>

                <tbody data-bind="template: {name: 'actionTemplate', foreach: filteredActions}">
                </tbody>

                <tfoot>
                <tr data-bind="visible: isLoading()">
                  <td colspan="10" class="left">
                    <img src="${ static('desktop/art/spinner.gif') }" />
                  </td>
                </tr>
                <tr data-bind="visible: !isLoading() && filteredActions().length == 0">
                  <td colspan="11">
                    <div class="alert">
                      ${ _('There are no actions to be shown.') }
                    </div>
                  </td>
                </tr>
                </tfoot>
              </table>

              <div class="pagination dataTables_paginate">
                <ul>
                  <li class="prev"><a href="javascript:void(0)" class="btn-actions-pagination" data-value="prev" data-table="actions"><i class="fa fa-long-arrow-left"></i> ${ _('Previous') }</a></li>
                  <li class="next"><a href="javascript:void(0)" class="btn-actions-pagination" data-value="next" data-table="actions">${ _('Next') } <i class="fa fa-long-arrow-right"></i></a></li>
                </ul>
              </div>
            </div>

            <script id="actionTemplate" type="text/html">
              <tr>
                <td data-bind="text: number"></td>
                <td data-bind="text: nominalTime"></td>
                <td data-bind="text: type"></td>
                <td><span data-bind="text: status, attr: {'class': statusClass}"></span></td>
                <td data-bind="text: errorCode"></td>
                <td data-bind="text: errorMessage"></td>
                <td data-bind="text: missingDependencies"></td>
                <td data-bind="text: createdTime"></td>
                <td data-bind="text: lastModifiedTime"></td>
                <td>
                  <a data-bind="visible:externalId !='', attr: {href: url}, text: id" data-row-selector"true"></a>
                </td>
                <td>
                  <a data-bind="visible:externalId !='', attr: {href: externalIdUrl}, text: externalId"></a>
                </td>
              </tr>
            </script>

            <div class="tab-pane" id="details">
              <table class="table table-condensed">
                <tbody>
                  <tr>
                    <td>${ _('Start time') }</td>
                    <td>${ utils.format_time(oozie_coordinator.startTime) }</td>
                  </tr>
                  <tr>
                    <td>${ _('End time') }</td>
                    <td>${ utils.format_time(oozie_coordinator.endTime) }</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="tab-pane" id="configuration">
              ${ utils.display_conf(oozie_coordinator.conf_dict) }
            </div>

            <div class="tab-pane" id="log">
              <pre></pre>
            </div>

            <div class="tab-pane" id="definition">
              <textarea id="definitionEditor">${ oozie_coordinator.definition.decode('utf-8', 'replace') }</textarea>
            </div>

            % if oozie_coordinator.has_sla:
            <div class="tab-pane" id="sla" style="padding-left: 20px">
              <div id="yAxisLabel" class="hide">${_('Time since Nominal Time in min')}</div>
              <div id="slaChart"></div>
              <table id="slaTable" class="table table-striped table-condensed hide">
                <thead>
                  <th>${_('Status')}</th>
                  <th>${_('Nominal Time')}</th>
                  <th>${_('Expected Start')}</th>
                  <th>${_('Actual Start')}</th>
                  <th>${_('Expected End')}</th>
                  <th>${_('Actual End')}</th>
                  <th>${_('Expected Duration')}</th>
                  <th>${_('Actual Duration')}</th>
                  <th>${_('SLA')}</th>
                </thead>
                <tbody>
                %for sla in oozie_slas:
                  <tr>
                    <td class="slaStatus">${sla['slaStatus']}</td>
                    <td><span class="nominalTime">${sla['nominalTime']}</span></td>
                    <td><span class="expectedStart">${sla['expectedStart']}</span></td>
                    <td><span class="actualStart">${sla['actualStart']}</span></td>
                    <td><span class="expectedEnd">${sla['expectedEnd']}</span></td>
                    <td><span class="actualEnd">${sla['actualEnd']}</span></td>
                    <td>${sla['expectedDuration']}</td>
                    <td>${sla['actualDuration']}</td>
                    <td><a href="${ url('oozie:list_oozie_sla') }#${ sla['id'] }"></a></td>
                  </tr>
                %endfor
                </tbody>
              </table>
            </div>
            % endif
          </div>

          <div class="clearfix">
            <div class="pull-left" style="margin-bottom: 16px">
              <a href="${ url('oozie:list_oozie_coordinators') }" class="btn">${ _('Back') }</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<div id="confirmation" class="modal hide">
  <div class="modal-header">
    <a href="#" class="close" data-dismiss="modal">&times;</a>
    <h3 class="confirmation_header"></h3>
  </div>
  <div id="update-endtime" class="span10">
    ${ utils.render_field_no_popover(update_endtime_form['end'], show_label=False) }
  </div>
  <div class="modal-body">
      <p class="confirmation_body"></p>
  </div>
  <div class="modal-footer danger hide">
    <a href="#" class="btn" data-dismiss="modal">${_('No')}</a>
    <a class="btn btn-danger btn-confirm disable-feedback" href="javascript:void(0);">${_('Yes')}</a>
  </div>
  <div class="modal-footer normal hide">
    <a href="#" class="btn" data-dismiss="modal">${_('No')}</a>
    <a class="btn btn-primary btn-confirm disable-feedback" href="javascript:void(0);">${_('Yes')}</a>
  </div>
  <div class="modal-footer update hide">
    <a href="#" class="btn" data-dismiss="modal">${_('Cancel')}</a>
    <a class="btn btn-primary btn-confirm disable-feedback" href="javascript:void(0);">${_('Update')}</a>
  </div>
</div>

<div id="rerun-coord-modal" class="modal hide"></div>

<script src="${ static('oozie/js/dashboard-utils.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/knockout.min.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/codemirror-3.11.js') }"></script>
<link rel="stylesheet" href="${ static('desktop/ext/css/codemirror.css') }">
<script src="${ static('desktop/ext/js/codemirror-xml.js') }"></script>
<script src="${ static('desktop/ext/js/moment-with-locales.min.js') }" type="text/javascript" charset="utf-8"></script>

% if oozie_coordinator.has_sla:
<script src="${ static('oozie/js/sla.utils.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.flot.min.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.flot.selection.min.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.flot.time.min.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/js/jquery.blueprint.js') }"></script>
% endif

<script>

  var setupjHueRowSelector = function () {
    $("a[data-row-selector='true']").jHueRowSelector();
  }

  var Action = function (action) {
    return {
      id: action.id,
      url: action.url,
      number: action.number,
      type: action.type,
      status: action.status,
      statusClass: "label " + getStatusClass(action.status),
      externalId: action.externalId,
      externalIdUrl: action.externalIdUrl,
      title: action.title,
      nominalTime: action.nominalTime,
      createdTime: action.createdTime,
      lastModifiedTime: action.lastModifiedTime,
      errorMessage: action.errorMessage,
      errorCode: action.errorCode,
      missingDependencies: action.missingDependencies,
      selected: ko.observable(false),
      handleSelect: function (row, e) {
        e.stopPropagation();
        this.selected(! this.selected());
        viewModel.allSelected(false);
      }
    };
  };

  var RunningCoordinatorActionsModel = function (actions) {
    var self = this;
    this.isLoading = ko.observable(true);

    this.actions = ko.observableArray(ko.utils.arrayMap(actions), function (action) {
      return new Action(action);
    });

    this.allSelected = ko.observable(false);

    this.filter = ko.observableArray([]);

    this.searchFilter = ko.observable('');

    this.select = function (filter) {
      ko.utils.arrayFilter(self.actions(), function(action) {
        if (action.status.toLowerCase() === filter) {
          action.selected(true);
        }
      });
    };

    this.clearAllSelections = function () {
      ko.utils.arrayFilter(self.actions(), function (action) {
        action.selected(false);
      });
      self.allSelected(false);
    };

    this.clearSelections = function (filter) {
      ko.utils.arrayFilter(self.actions(), function (action) {
        if (action.status.toLowerCase() === filter) {
          action.selected(false);
        }
      });
      self.allSelected(false);
    };

    this.selectAll = function () {
      var regexp;

      if (! Array.isArray(self.filter())) {
        ko.utils.arrayForEach(self.actions(), function (action) {
          regexp = new RegExp(self.filter());

          self.allSelected(! self.allSelected());

          if (regexp.test(action.title.toLowerCase())) {
            action.selected(! action.selected());
          }
        });
        return true;
      }

      self.allSelected(! self.allSelected());

      ko.utils.arrayForEach(self.actions(), function (action) {
        if (action.id) {
          action.selected(self.allSelected());
        }
      });
      return true;
    };

    this.selectedActions = ko.computed(function () {
      var actionlist = [];

      ko.utils.arrayFilter(self.actions(), function (action) {
        if (action.selected()) {
          actionlist.push(action.number.toString());
        }
      });
      return actionlist;
    });

    this.searchFilter.subscribe(function () {
      if (self.searchFilter().length === 0) {
        self.filter([]);
      } else {
        self.filter(self.searchFilter().toLowerCase());
      }

      if (self.selectedActions().length === self.actions().length) {
        self.allSelected(true);
      } else {
        self.allSelected(false);
      }
    });

    this.filteredActions = ko.computed(function () {
      var filter = self.filter(),
        actions = [],
        regexp,
        data;

      if (self.filter().length === 0) {
        return self.actions();
      }

      ko.utils.arrayFilter(self.actions(), function (action) {
        if ($.inArray(filter.toString(), ['succeeded', 'running', 'failed']) === -1) {
          regexp = new RegExp(filter);
          if (regexp.test(action.title.toLowerCase())) {
            actions.push(action);
          }
        }
      });

      if (Array.isArray(self.filter())) {
        data = self.actions()
      } else {
        data = actions;
      }

      return data;
    });
  };

  var viewModel = new RunningCoordinatorActionsModel([]);
  ko.applyBindings(viewModel);

  var CHART_LABELS = {
    NOMINAL_TIME: "${_('Nominal Time')}",
    EXPECTED_START: "${_('Expected Start')}",
    ACTUAL_START: "${_('Actual Start')}",
    EXPECTED_END: "${_('Expected End')}",
    ACTUAL_END: "${_('Actual End')}",
    TOOLTIP_ADDON: "${_('click for the SLA dashboard')}"
  }
  var slaTable, refreshViewTimer;
  var PAGE_SIZE = 50;
  var actionTableOffset = 1;


  $(document).ready(function(){
    $("a[data-row-selector='true']").jHueRowSelector();

    $("*[rel=tooltip]").tooltip();

    $(".dataset").each(function () {
      if ($(this).text().length > 15) {
        $(this).html($(this).text().substr(0, 14) + "&hellip;");
      }
      $(this).removeClass("hide");
    });

    % if oozie_coordinator.has_sla:
    slaTable = $("#slaTable").dataTable({
      "bPaginate": false,
      "bLengthChange": false,
      "bInfo": false,
      "bAutoWidth": false,
      "oLanguage": {
        "sEmptyTable": "${_('No data available')}",
        "sZeroRecords": "${_('No matching records')}"
      }
    });

    $(".dataTables_wrapper").css("min-height", "0");
    $(".dataTables_filter").hide();
    % endif

    var definitionEditor = $("#definitionEditor")[0];

    var codeMirror = CodeMirror(function(elt) {
      definitionEditor.parentNode.replaceChild(elt, definitionEditor);
      }, {
        value: definitionEditor.value,
      readOnly: true,
      lineNumbers: true
    });

    // force refresh on tab change
    $("a[data-toggle='tab']").on("shown", function (e) {
      if ($(e.target).attr("href") == "#definition") {
        codeMirror.refresh();
      }
      % if oozie_coordinator.has_sla:
      if ($(e.target).attr("href") == "#sla") {
        window.setTimeout(function () {
          updateSLAChart(slaTable, CHART_LABELS, 30); // limits to 30 results
        }, 100)
      }
      % endif
    });

    $("a.btn-status").click(function () {
      var val = $(this).data("value")
      var btnCalendar = $("a.btn-status[data-table='calendar'][data-value='"+ val + "']");
      var btnAction = $("a.btn-status[data-table='actions'][data-value='"+ val + "']");

      refreshActionsPagination();
      btnCalendar.toggleClass("active");
      btnAction.toggleClass("active");
      refreshView();
    });

    $("a.btn-actions-pagination").on("click", function () {
      if (!$(this).parent().hasClass("disabled")) {
        var _additionalOffset = 0;
        if ($(this).data("value") == "prev") {
          actionTableOffset -= PAGE_SIZE;
        }
        else {
          actionTableOffset += PAGE_SIZE;
        }
        refreshView();
      }
    });

    $(".confirmationModal").click(function () {
      var _this = $(this);
      $("#confirmation .confirmation_header").text(_this.attr("data-confirmation-header"));
      if (_this.hasClass("ignore-btn")) {
        $("#confirmation .confirmation_body").text(_this.attr("data-confirmation-body"));
      }
      $("#confirmation .modal-footer:not(." + _this.attr("data-confirmation-footer") + ")").addClass("hide");
      $("#confirmation .modal-footer." + _this.attr("data-confirmation-footer")).removeClass("hide");
      $("#confirmation").modal("show");

      if (_this.attr("id") == "edit-endtime-btn") {
        $("#update-endtime").show();
      } else {
        $("#update-endtime").hide();
      }

      $("#confirmation a.btn-confirm").unbind();
      $("#confirmation a.btn-confirm").click(function () {
        _this.trigger('confirmation');
        $(this).attr("data-loading-text", $(this).text() + " ...");
        $(this).button("loading");
      });
    });

    $(".confirmationModal").bind('confirmation', function () {
      var _this = this;
      var IN_DATETIME_FORMAT = "MM/DD/YYYY hh:mm A";
      var OUT_DATETIME_FORMAT = "YYYY-MM-DD[T]HH:mm[Z]";

      var params = { 'notification': $(_this).attr("data-message") };
      if ($(this).attr("id") == "edit-endtime-btn") {
        params['end_time'] = moment($("input[name='end_0']").val() + " " + $("input[name='end_1']").val(),
            IN_DATETIME_FORMAT).format(OUT_DATETIME_FORMAT);
      }
      else if ($(this).hasClass("ignore-btn")) {
        params['actions'] = viewModel.selectedActions().join(' ');
      }

      $.post($(this).attr("data-url"), params,
          function (response) {
            if (response['status'] != 0) {
              $(document).trigger("error", "${ _('Problem: ') }" + response['data']);
              $("#confirmation a.btn-confirm").button("reset");
              $("#confirmation").modal("hide");
            } else {
              window.location.reload();
            }
          }
      );
      return false;
    });

    $("#suspend-btn").bind('confirmation', function () {
      var _this = this;
      $.post($(this).data("url"),
          { 'notification': $(this).data("message") },
          function (response) {
            if (response['status'] != 0) {
              $(document).trigger("error", "${ _('Error: ') }" + response['data']);
              $("#confirmation a.btn-confirm").button("reset");
            } else {
              window.location.reload();
            }
          }
      );
      return false;
    });

    $('#rerun-btn, .rerun-btn').click(function () {
      var _action = $(this).data("rerun-url");

      $.get(_action, function (response) {
        $('#rerun-coord-modal').html(response);
        $('#rerun-coord-modal').modal('show');
      });
    });

    function refreshActionsPagination() {
      actionTableOffset = 1;
    }

    function getFilteredStatuses(type) {
      var selectedStatuses = '';
      var btnStatuses = [];
      $.each($("a.btn-status.active[data-table='calendar']"), function () {
        val = $(this).data('value');
        if (val == 'SUCCEEDED') {
          btnStatuses = btnStatuses.concat(['SUCCEEDED']);
        } else if (val == 'RUNNING') {
          btnStatuses = btnStatuses.concat(['RUNNING', 'READY', 'SUBMITTED', 'SUSPENDED', 'WAITING']);
        } else if (val == 'ERROR') {
          btnStatuses = btnStatuses.concat(['KILLED', 'FAILED', 'TIMEDOUT', 'IGNORED', 'SKIPPED']);
        }
      });

      $.each(btnStatuses, function (iStatus, status) {
        selectedStatuses += '&status=' + status;
      });
      return selectedStatuses;
    }

    resizeLogs();
    refreshView();
    refreshLogs();

    var logsAtEnd = true;
    function refreshLogs() {
      $.getJSON("${ url('oozie:get_oozie_job_log', job_id=oozie_coordinator.id) }", function (data) {
        var _logsEl = $("#log pre");
        _logsEl.text(data.log);

        if (logsAtEnd) {
          _logsEl.scrollTop(_logsEl[0].scrollHeight - _logsEl.height());
        }
        if (data.status != "RUNNING" && data.status != "PREP"){
          return;
        }
        window.setTimeout(refreshLogs, 20000);
      });
    }

    function refreshActionPaginationButtons(totalJobs) {
      var prevBtnActions = $("a.btn-actions-pagination[data-table='actions'][data-value='prev']");
      var nextBtnActions = $("a.btn-actions-pagination[data-table='actions'][data-value='next']");
      var prevBtnCalendar = $("a.btn-actions-pagination[data-table='calendar'][data-value='prev']");
      var nextBtnCalendar = $("a.btn-actions-pagination[data-table='calendar'][data-value='next']");

      if (actionTableOffset == 1 || !totalJobs) {
        prevBtnActions.parent().addClass("disabled");
        prevBtnCalendar.parent().addClass("disabled");
      }
      else {
        prevBtnActions.parent().removeClass("disabled");
        prevBtnCalendar.parent().removeClass("disabled");
      }
      if (totalJobs < (actionTableOffset + PAGE_SIZE) || !totalJobs) {
        nextBtnActions.parent().addClass("disabled");
        nextBtnCalendar.parent().addClass("disabled");
      }
      else if (totalJobs >= actionTableOffset + PAGE_SIZE) {
        nextBtnActions.parent().removeClass("disabled");
        nextBtnCalendar.parent().removeClass("disabled");
      }
    }

    function refreshView() {
      window.clearTimeout(refreshViewTimer);
      $.getJSON("${ oozie_coordinator.get_absolute_url(oozie_bundle=oozie_bundle, format='json') }" + "&offset=" + actionTableOffset + getFilteredStatuses(), function (data) {
        viewModel.isLoading(false);

        // Getting selected status from previous action list
        updatedActionList = [];
        if (data != null && data.actions){
          var prevActions = viewModel.actions();
          $(data.actions).each(function (iAction, action) {
            var actionItem = new Action(action);
            $(prevActions).each(function (iPrev, prev) {
              if (prev.id == actionItem.id) {
                actionItem.selected(prev.selected());
              }
            });
            updatedActionList.push(actionItem);
          });
        }
        viewModel.actions(updatedActionList);

        // Refresh actions pagination
        totalActions = data.total_actions;
        refreshActionPaginationButtons(totalActions);

        $("#status span").attr("class", "label").addClass(getStatusClass(data.status)).text(data.status);

        $.jHueTitleUpdater.set(data.progress + "%");

        if (data.id && data.status != "RUNNING" && data.status != "SUSPENDED" && data.status != "KILLED" && data.status != "FAILED"){
          $("#kill-btn").hide();
        }

        if (data.id && data.status != "KILLED" && data.status != "FAILED"){
          $("#rerun-btn").show();
        } else {
          $("#rerun-btn").hide();
        }

        if (data.id && (data.status == "RUNNING" || data.status == "RUNNINGWITHERROR")){
          $("#suspend-btn").show();
        } else {
          $("#suspend-btn").hide();
        }

        if (data.id && (data.status == "SUSPENDED" || data.status == "SUSPENDEDWITHERROR" || data.status == "SUSPENDEDWITHERROR"
            || data.status == "PREPSUSPENDED")){
          $("#resume-btn").show();
          $.jHueTitleUpdater.reset();
        } else {
          $("#resume-btn").hide();
        }

        $("#progress .bar").text(data.progress + "%").css("width", data.progress + "%").attr("class", "bar " + getStatusClass(data.status, "bar-"));

        if (data.status != "RUNNING" && data.status != "PREP"){
          return;
        }

        refreshViewTimer = window.setTimeout(refreshView, 5000);
      });
    }

    $(window).resize(function () {
      resizeLogs();
    });

    $("a[href='#log']").on("shown", function () {
      resizeLogs();
    });

    $("#log pre").scroll(function () {
      if ($(this).scrollTop() + $(this).height() + 20 >= $(this)[0].scrollHeight) {
        logsAtEnd = true;
      }
      else {
        logsAtEnd = false;
      }
    });

    function resizeLogs() {
      $("#log pre").css("overflow", "auto").height($(window).height() - $("#log pre").position().top - 80);
    }

    if (window.location.hash == "#showSla") {
      $("a[href='#sla']").click();
    }
  });
</script>

${ utils.decorate_datetime_fields() }

${ commonfooter(messages) | n,unicode }
