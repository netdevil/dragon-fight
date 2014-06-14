/**
 * Created by Draco on 09.06.14.
 */
/*! angular-test 2013-12-11 */
angular.module("angular-json-rpc",[]).config(["$provide",function(a){return a.decorator("$http",["$delegate",function(a){return a.jsonrpc=function(b,c,d,e){var f={jsonrpc:"2.0",method:c,params:d,id:1};return a.post(b,f,angular.extend({headers:{"Content-Type":"application/json"}},e))},a}])}]);

angular.module('test-module-jsonrpc', ['angular-json-rpc'])
    .controller('TestController', ['$scope', '$http' , function (scope, $http) {
        scope.team = ["Loading..."];
        scope.refresh = function(){
            //url, method, parameters, config
            $http.jsonrpc('http://rcs.dev/local/rcs-angular/rpc.php', 'methodToCall', [1, 2, 3])
                .success(function(data, status, headers, config){
                    if (typeof data.result !== 'undefined' && data.result.team) {
                        scope.team = data.result.team;
                        scope.name = data.result.name;
                        scope.show = 'block';
                        console.log(scope.show);
                    } else {
                        scope.team = ["Unable to retrieve team members"];
                        scope.show = 'none';
                        console.log(scope.show);
                    }

                }).error(function(data, status, headers, config){
                    scope.team = ["Unable to retrieve team members because the request failed"];
                });
        };
        scope.refresh();
    }]
);
