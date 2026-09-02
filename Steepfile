D = Steep::Diagnostic

target :app do
  signature 'sig'
  check 'lib'
  check 'app'
  configure_code_diagnostics(D::Ruby.lenient)
end

target :spec do
  unreferenced!                     # Skip type checking the `lib` code when types in `test` target is changed
  signature 'sig/spec'              # Put RBS files for tests under `sig/test`
  check 'spec'                      # Type check Ruby scripts under `test`

  configure_code_diagnostics(D::Ruby.lenient) # Weak type checking for test code
end
