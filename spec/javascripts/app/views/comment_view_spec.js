describe("app.views.Comment", function(){
  beforeEach(function(){
    this.post = factory.post({author : {lygneo_id : "xxx@xxx.xxx"}})
    this.comment = factory.comment({parent : this.post.toJSON()})
    this.view = new app.views.Comment({model : this.comment})
  })

  describe("render", function(){
    it("has a delete link if the author is the current user", function(){
      loginAs(this.comment.get("author"))
      expect(this.view.render().$('.delete').length).toBe(1)
    })

    it("doesn't have a delete link if the author is not the current user", function(){
      loginAs(factory.author({lygneo_id : "notbob@bob.com"}))
      expect(this.view.render().$('.delete').length).toBe(0)
    })

    it("doesn't have a delete link if the user is logged out", function(){
      logout()
      expect(this.view.render().$('.delete').length).toBe(0)
    })
  })

  describe("ownComment", function(){
    it("returns true if the author lygneo_id == the current user's lygneo_id", function(){
      loginAs(this.comment.get("author"))
      expect(this.view.ownComment()).toBe(true)
    })

    it("returns false if the author lygneo_id != the current user's lygneo_id", function(){
      loginAs(factory.author({lygneo_id : "notbob@bob.com"}))
      expect(this.view.ownComment()).toBe(false);
    })
  })

  describe("postOwner", function(){
    it("returns true if the author lygneo_id == the current user's lygneo_id", function(){
      loginAs(this.post.get("author"))
      expect(this.view.postOwner()).toBe(true)
    })

    it("returns false if the author lygneo_id != the current user's lygneo_id", function(){
      loginAs(factory.author({lygneo_id : "notbob@bob.com"}))
      expect(this.view.postOwner()).toBe(false);
    })
  })

  describe("canRemove", function(){
    context("is truthy", function(){
      it("when ownComment is true", function(){
        spyOn(this.view, "ownComment").andReturn(true)
        spyOn(this.view, "postOwner").andReturn(false)

        expect(this.view.canRemove()).toBe(true)
      })

      it("when postOwner is true", function(){
        spyOn(this.view, "postOwner").andReturn(true)
        spyOn(this.view, "ownComment").andReturn(false)

        expect(this.view.canRemove()).toBe(true)
      })
    })

    context("is falsy", function(){
      it("when postOwner and ownComment are both false", function(){
        spyOn(this.view, "postOwner").andReturn(false)
        spyOn(this.view, "ownComment").andReturn(false)

        expect(this.view.canRemove()).toBe(false)
      })
    })
  })
})
