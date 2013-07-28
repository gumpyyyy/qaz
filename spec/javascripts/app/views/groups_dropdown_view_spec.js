describe("app.views.GroupsDropdown", function () {
  function selectedGroups(view){
    return _.pluck(view.$("input.group_ids").serializeArray(), "value")
  }

  beforeEach(function () {
    loginAs({
      groups:[
        { id:3, name:"sauce" },
        { id:5, name:"conf" },
        { id:7, name:"lovers" }
      ]
    })

    this.view = new app.views.GroupsDropdown({model:factory.statusMessage({group_ids:undefined})})
  })

  describe("rendering", function () {
    beforeEach(function () {
      this.view.render()
    })
    it("sets group_ids to 'public' by default", function () {
      expect(this.view.$("input.group_ids:checked").val()).toBe("public")
    })

    it("defaults to Public Visibility", function () {
      expect(this.view.$("input.group_ids.public")).toBeChecked()
      expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("Public")
    })

    it("sets group_ids to 'public'", function () {
      expect(selectedGroups(this.view)).toEqual(["public"])
    })

    it("sets the dropdown title to 'public'", function () {
      expect(this.view.$(".dropdown-toggle .text").text()).toBe("Public")
    })

    describe("setVisibility", function () {
      function checkInput(input){
        input.attr("checked", "checked")
        input.trigger("change")
      }

      function uncheckInput(input){
        input.attr("checked", false)
        input.trigger("change")
      }

      describe("selecting All Groups", function () {
        beforeEach(function () {
          this.input = this.view.$("input#group_ids_all_groups")
          checkInput(this.input)
        })

        it("calls set group_ids to 'all'", function () {
          expect(selectedGroups(this.view)).toEqual(["all_groups"])
        })

        it("sets the dropdown title to 'public'", function () {
          expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("All Groups")
        })
      })

      describe("selecting An Group", function () {
        beforeEach(function () {
          this.input = this.view.$("input[name='lovers']")
          checkInput(this.input)
        })

        it("sets the dropdown title to the group title", function () {
          expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("lovers")
        })

        it("sets group_ids to to the group id", function () {
          expect(selectedGroups(this.view)).toEqual(["7"])
        })

        describe("selecting another group", function () {
          beforeEach(function () {
            this.input = this.view.$("input[name='sauce']")
            checkInput(this.input)
          })

          it("sets group_ids to the selected groups", function () {
            expect(selectedGroups(this.view)).toEqual(["3", "7"])
          })

          it("sets the button text to the number of selected groups", function () {
            expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 2 groups")
            checkInput(this.view.$("input[name='conf']"))
            expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 3 groups")
            uncheckInput(this.view.$("input[name='conf']"))
            expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 2 groups")
          })

          describe("deselecting another group", function () {
            it("removes the clicked group", function () {
              expect(selectedGroups(this.view)).toEqual(["3", "7"])
              expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("In 2 groups")
              uncheckInput(this.view.$("input[name='lovers']"))
              expect(selectedGroups(this.view)).toEqual(["3"])
              expect($.trim(this.view.$(".dropdown-toggle .text").text())).toBe("sauce")
            })
          })

          describe("selecting all_groups", function () {
            it("sets group_ids to all_groups", function () {
              expect(selectedGroups(this.view)).toEqual(["3", "7"])
              checkInput(this.view.$("input[name='All Groups']"))
              expect(selectedGroups(this.view)).toEqual(["all_groups"])
            })
          })

          describe("selecting public", function () {
            it("sets group_ids to public", function () {
              expect(selectedGroups(this.view)).toEqual(["3", "7"])
              checkInput(this.view.$("input[name='Public']"))
              expect(selectedGroups(this.view)).toEqual(["public"])
            })
          })
        })
      })
    })
  })
})