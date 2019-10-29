# Author Marek Pietrucha
# https://github.com/mareczek/international-phone-number
(function () {
    "use strict";
    angular.module("internationalPhoneNumber", []).constant('ipnConfig', {
        allowExtensions: false,
        autoFormat: true,
        autoHideDialCode: true,
        autoPlaceholder: true,
        customPlaceholder: null,
        defaultCountry: "",
        geoIpLookup: null,
        nationalMode: true,
        numberType: "MOBILE",
        onlyCountries: [],
        preferredCountries: ['us', 'gb'],
        skipUtilScriptDownload: false,
        utilsScript: ""
    }).directive('internationalPhoneNumber', [
        '$timeout', 'ipnConfig', function ($timeout, ipnConfig) {
            return {
                restrict: 'A',
                require: '^ngModel',
                scope: {
                    ngModel: '=',
                    country: '='
                },
                link: function (scope, element, attrs, ctrl) {
                    let iti = window.intlTelInput(element[0], ipnConfig);

                    let read, watchOnce;
                    if (ctrl) {
                        if (element.val() !== '') {
                            $timeout(function () {
                                iti.setNumber(element.val());
                                return ctrl.$setViewValue(element.val());
                            }, 0);
                        }
                    }
                    read = function () {
                        return ctrl.$setViewValue(element.val());
                    };

                    watchOnce = scope.$watch('ngModel', function (newValue) {
                        //$$postDigest运行一次就销毁
                        return scope.$$postDigest(function () {
                            if (newValue !== null && newValue !== void 0 && newValue.length > 0) {
                                if (newValue[0] !== '+') {
                                    newValue = '+' + newValue;
                                }
                                ctrl.$modelValue = newValue;
                            }
                            return watchOnce();
                        });
                    });
                    scope.$watch('country', function (newValue) {
                        if (newValue !== null && newValue !== void 0 && newValue !== '' && !scope.ngModel) {
                            return iti.setCountry(newValue && newValue.toLowerCase() || 'cn');
                        }
                    });
                    ctrl.$formatters.push(function (value) {
                        if (!value) {
                            return value;
                        }
                        iti.setNumber(value);
                        return value;
                    });
                    ctrl.$parsers.push(function (value) {
                        if (!value) {
                            return value;
                        }
                        return iti.getNumber();
                    });
                    ctrl.$validators.internationalPhoneNumber = function (value) {
                        let selectedCountry;
                        selectedCountry = window.intlTelInputGlobals.getCountryData();
                        if (!value || (selectedCountry && selectedCountry.dialCode === value)) {
                            return true;
                        }
                        return iti.isValidNumber();
                    };
                    element.on('blur keyup change', function (event) {
                        return scope.$apply(read);
                    });
                    return element.on('$destroy', function () {
                        iti.destroy();
                        return element.off('blur keyup change');
                    });

                }
            };
        }
    ]);

}).call(this);

