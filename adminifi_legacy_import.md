# How does this apply to adminifi import

Here is the structure that it is talked in the sidekiq wiki:
![complex flow](https://raw.githubusercontent.com/mperham/sidekiq/master/examples/complex_batch_workflow.png)

`ImportBatchUploader` is the main entry point of the import service.
In here we create a batch for each organization.

Job A from the image represent each `ImportOrganizationDataWorker` that is launched.
Inside job A we run some computations and then launch a series of workers (that can run in parallel) to
import users. All this workers are run inside a batch.

Jobs B->F can be identified to all instances of `ImportUserDataWorker` created.
After jobs B->F have run, we need to launch a new worker to handle the CS import. We do this on the 
`on_complete` callback for the batch: finished_user_import.

Job G represents the instance of `ImportCSData`.
In our scenario, job G is the last one in line. So, after that is finished we need to come back and
update the import batch resource with a summary of the import. This will be done via an `on_complete` callback:
finished_adminifi_import.

### What I did wrong before

I was doing something like:
```
1.  class ImportBatchUploader
2.   # ...
3.   def perform
4.     # ...
5.     batch = Sidekiq::Batch.new
6.     batch.on :complete, '...#finished_adminifi_import'
7.
8.     batch.jobs do
9.      ImportOrganizationDataWorker.perform_async()
10.    end 
11.    # ... 
12.   end
13.   # ...
14.  end
15.
16. class ImportOrganizationDataWorker
17.  # ...
18.  def perform
19.    # ...
20.    import_users
21.    # ... 
22.  end
23.  
24.  def import_users
25.    batch = Sidekiq::Batch.new
26.    batch.on :complete, '...#finished_user_import'
27.    batch.jobs do
28.      data.each do |user_data|
29.        ImportUserDataWorker.perform_async(user_data)
30.      end
31.    end
32.  end
33.  # ...
34.end
```

The issue can be identified on lines 25-31. I was creating a new batch object and adding jobs to it.

Instead I should have added jobs to the `batch` object from ImportBatchUploader.

Correct implementation:
```
24.  def import_users
27.    batch.jobs do
28.     user_batch = Sidekiq::Batch.new 
29.     user_batch.on :complete, '...#finished_user_import'
30.     user_batch.jobs do
31.       data.each do |user_data|
32.         ImportUserDataWorker.perform_async(user_data)
33.       end
34.     end
35.    end
36.  end
```

### Conclusions

Batches are very powerful when used correctly.

You can nest as many batches you want, just keep in mind to add the jobs to the parent_batch.

If batches are defined correctly, `on_complete` and `on_success` callbacks are a good way to gather info.
