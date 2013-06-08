
if (jasmine && jasmine.Matchers) {
  jasmine.Matchers.prototype.toBeInstanceOf = function(klass) {
    return this.actual instanceof klass;
  };
}
