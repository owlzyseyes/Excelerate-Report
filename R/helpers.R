#' Caption text
#'
#' @param accent Colour of icon
#' @param data Name of data
#'
#' @return
#' @export
make_caption <- function(accent, bg, data) {

  if(length(accent) != 3) {
    accent <- rep(accent[1], 3)
  }

  github <- glue("<span style='font-family:fa-brands; color:{accent[1]}'>&#xf09b;</span>")
  bluesky <- glue("<span style='font-family:fa-brands; color:{accent[2]}'>&#xe671;</span>")
  linkedin <- glue("<span style='font-family:fa-brands; color:{accent[3]}'>&#xf08c;</span>")

  twitter <- glue("<span style='font-family:fa-brands; color:{accent}'>&#xf099;</span>")
  threads <- glue("<span style='font-family:fa-brands; color:{accent}'>&#xe618;</span>")
  mastodon <- glue("<span style='font-family:fa-brands; color:{accent}'>&#xf4f6;</span>")
  floppy <- glue("<span style='font-family:fa-solid; color:{accent}'>&#xf0c7;</span>")

  space <- glue("<span style='color:{bg};font-size:1px'>''</span>")
  space2 <- glue("<span style='color:{bg}'>-</span>") # can't believe I'm doing this

  glue("
       {github} {space} owlzyseyes{space2}
       {bluesky} {space} @hootist.bsky.social {space2}
       {linkedin} {space} Brian Mubia
       ")
}