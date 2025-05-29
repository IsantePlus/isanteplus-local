var app = angular.module('arvByPeriodReport', ['ui.bootstrap']).

    filter('translate', function() {
        return function(input, prefix) {
            if (input && input.uuid) {
                input = input.uuid;
            }
            var code = prefix ? prefix + input : input;
            return emr.message(code, input);
        }
    }).

    controller('ArvByPeriodReportController', ['$scope', '$http', '$timeout', function($scope, $http, $timeout) {

        function dataFor(date) {
            return $scope.data[date.getTime()];
        }
        function dataEnd(date) {
            return $scope.data[date.getTime()];
        }

        $scope.data = { };

        $scope.viewingCohort = null;

        $scope.maxstartDate = moment().startOf('startDate').toDate();

        $scope.startDate = moment().startOf('startDate').toDate(); // default to tostartDate
        
        $scope.maxstartDateStop = moment().startOf('endDate').toDate();

        $scope.endDate = moment().startOf('endDate').toDate(); // default to tostartDate

        $scope.$watch('startDate','endDate', function() {
            $scope.viewingCohort = null;
        });

        $scope.currentData = function() {
            var startDate = $scope.startDate;
            var endDate = $scope.endDate;
            if (!dataFor(startDate) && !dataFor(endDate)) {
                evaluate(startDate,endDate);
            }
            return dataFor(startDate) && dataFor(endDate);
        }

        $scope.openDatePicker = function() {
            $timeout(function() {
                $scope.isDatePickerOpen = true;
            });
        };

        $scope.isLoading = function() {
            return dataFor($scope.startDate) && dataFor($scope.startDate).loading;
        };

        $scope.hasResults = function() {
            return dataFor($scope.startDate) && dataFor($scope.startDate).dataSets;
        };

        $scope.hasResultsWithMembers = function() {
            var data = dataFor($scope.startDate);
            if (!data || data.loading) {
                return false;
            }
            for (var i = 0; i < data.dataSets.length; ++i) {
                var ds = data.dataSets[i];
                for (var j = 0; j < ds.rows.length; ++j) {
                    var row = ds.rows[j];
                    for (var key in row) {
                        if (row[key].size) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        $scope.hasAnyNonEmptyCohort = function(rowOrDataset) {
            if (rowOrDataset.rows) { // it's a dataset
                for (var i = 0; i < rowOrDataset.rows.length; ++i) {
                    if ($scope.hasAnyNonEmptyCohort(rowOrDataset.rows[i])) {
                        return true;
                    }
                }
                return false;
            } else { // it's a row
                for (key in rowOrDataset) {
                    if (rowOrDataset[key].size) {
                        return true;
                    }
                }
                return false;
            }
        }

        function evaluate(startDate, endDate) {
            var forstartDate = new Date(startDate.getTime());
            var forendDate = new Date(endDate.getTime());
            if (dataFor(forstartDate) && dataFor(forendDate)) {
                return;
            }

            $scope.data[forstartDate.getTime()] = { loading: true };
            $scope.data1[forendDate.getTime()] = { loading: true };
            $http.get('/' + OPENMRS_CONTEXT_PATH + '/ws/rest/v1/reportingrest/reportdata/' + window.reportDefinition.uuid + '?startDate=' + moment(forstartDate).format('YYYY-MM-DD') + '&endDate=' + moment(forendDate).format('YYYY-MM-DD')).
                success(function(data, data1, status, headers, config) {
                    $scope.data[forstartDate.getTime()] = data;
                    $scope.data1[forendDate.getTime()] = data1;
                });
        }

        $scope.viewCohort = function(startDate, endDate, row, column) {
            startDate = new Date(startDate.getTime());
            endDate = new Date(endDate.getTime());
            var ptIds = row[column.name].memberIds;
            if (ptIds == null || ptIds.length == 0) {
                $scope.viewingCohort = null;
                return;
            }

            $scope.viewingCohort = { loading: true };

            $http.get(emr.fragmentActionLink('isanteplusreports', 'cohort', 'getCohort',
                    {
                        memberIds: ptIds
                    })).
                success(function(data, status, headers, config) {
                    $scope.viewingCohort = {
                        row: row,
                        column: column,
                        startDate: startDate,
                        endDate: endDate,
                        members: data.members
                    };
                });
        }

        evaluate($scope.startDate,$scope.endDate);
    }]);
