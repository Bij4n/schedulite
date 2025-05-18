class EmptyStateComponent < ViewComponent::Base
  def initialize(title:, description:)
    @title = title
    @description = description
  end

  def call
    tag.div(class: "flex flex-col items-center justify-center py-16 text-center") do
      safe_join([
        tag.div(class: "mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-teal-50 dark:bg-teal-900/30") do
          tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "h-6 w-6 text-teal-600") do
            tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5")
          end
        end,
        tag.h3(@title, class: "text-sm font-semibold text-gray-900 dark:text-gray-100"),
        tag.p(@description, class: "mt-1 text-sm text-gray-500 dark:text-gray-400")
      ])
    end
  end
end
