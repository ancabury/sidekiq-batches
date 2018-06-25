# searchkiq-batches
This repo illustrates a sample app on how to use sidekiq batches in a complex flow.

Versions used in this repo:
* ruby (2.4.3)
* sidekiq (5.1.3)
* sidekiq-ent (1.7.1)
* sidekiq-pro (4.0.3)


This project is an illustration of the a complex flow described [here](https://github.com/mperham/sidekiq/wiki/Really-Complex-Workflows-with-Batches).

## Autoload project files

Files for this project are automatically loaded using `~/.irbrc` file and `.irbrc.rb` from the project.
To have this working append the following code to `~/.irbrc` on your machine and run `irb` from the projects 
root.

```ruby
begin
  # check for an .irbrc file in the current dir and try to load it
  current_dir = Dir.pwd
  local_irbrc = "#{current_dir}/.irbrc"

  require local_irbrc
rescue LoadError => e
  p 'The file `.irbrc.rb` might be missing from this document.'
  p 'Add this file to the root of your folder if you need files to be autoloaded in irb session'
  p e
end
```


## Running the app

`sidekiq -r ./config/boot.rb -C ./config/sidekiq.yml`

Run: `irb` and call WorkflowWorker with a number of jobs like `WorkflowWorker.new(50).perform`
