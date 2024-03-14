import { request, expect } from "@playwright/test";
import config from "../../../playwright.config";

const contextPromise = request.newContext({
  baseURL: config.use ? config.use.baseURL : "http://localhost:5017",
});

const appCommands = async (data: { name: any; options: {} }) => {
  const context = await contextPromise;
  const response = await context.post("/__e2e__/command", { data });

  expect(response.ok()).toBeTruthy();
  return response.body;
};

const app = (name: string, options = {}) =>
  appCommands({ name, options }).then((body) => body[0]);
const appScenario = (name: string, options = {}) =>
  app("scenarios/" + name, options);
const appEval = (code: {} | undefined) => app("eval", code);
const appFactories = (options: {} | undefined) => app("factory_bot", options);

const appVcrInsertCassette = async (cassette_name: string, options = {}) => {
  const context = await contextPromise;
  if (!options) options = {};

  Object.keys(options).forEach((key) =>
    options[key] === undefined ? delete options[key] : {},
  );
  const response = await context.post("/__e2e__/vcr/insert", {
    data: [cassette_name, options],
  });
  expect(response.ok()).toBeTruthy();
  return response.body;
};

const appVcrEjectCassette = async () => {
  const context = await contextPromise;

  const response = await context.post("/__e2e__/vcr/eject");
  expect(response.ok()).toBeTruthy();
  return response.body;
};

export {
  appCommands,
  app,
  appScenario,
  appEval,
  appFactories,
  appVcrInsertCassette,
  appVcrEjectCassette,
};
