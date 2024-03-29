/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Follower List", function() {
    describe("disconnectUser", function() {
      it("does an ajax call to person delete with the passed in id", function(){
        var id = '3';
        spyOn($,'ajax');
        List.disconnectUser(id);
        expect($.ajax).toHaveBeenCalled();
        var option_hash = $.ajax.mostRecentCall.args[0];
        expect(option_hash.url).toEqual("/followers/" + id);
        expect(option_hash.type).toEqual("DELETE");
        expect(option_hash.success).toBeDefined();
      });
  });
});
